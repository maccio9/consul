class Proposal < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Flaggable
  include Taggable
  include Conflictable
  include Measurable
  include Sanitizable
  include Searchable
  include Filterable
  include HasPublicAuthor
  include Graphqlable
  include Followable
  include Communitable
  include Imageable
  include Mappable
  include Notifiable
  include Documentable
  documentable max_documents_allowed: 1,
               max_file_size: 3.megabytes,
               accepted_content_types: [ "application/pdf" ]
  include EmbedVideosHelper
  include Relationable

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  RETIRE_OPTIONS = %w(duplicated started unfeasible done other)
  AUTHOR_TYPES = {personal_title: 0, state_organism: 1, organized_society: 2, academy: 3, private_sector: 4}

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :geozone
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :proposal_notifications, dependent: :destroy

  validates :title, presence: true
  validates :summary, presence: true
  validates :geozone_id, presence: true, if: :group_is_visible?
  validates :author, presence: true
  validates :tag_list, presence: true, if: :categories_is_visible?
  validates :title, length: { in: 4..Proposal.title_max_length }
  validates :description, length: { maximum: Proposal.description_max_length }
  validates :retired_reason, inclusion: { in: RETIRE_OPTIONS, allow_nil: true }

  #validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  validate :valid_video_url?

  validates :responsible_name, presence: true, if: -> {author_type != AUTHOR_TYPES[:personal_title]}

  before_save :calculate_hot_score, :calculate_confidence_score

  scope :for_render,               -> { includes(:tags) }
  scope :sort_by_hot_score,        -> { reorder(hot_score: :desc) }
  scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc) }
  scope :sort_by_created_at,       -> { reorder(created_at: :desc) }
  scope :sort_by_most_commented,   -> { reorder(comments_count: :desc) }
  scope :sort_by_random,           -> { reorder("RANDOM()") }
  scope :sort_by_relevance,        -> { all }
  scope :sort_by_flags,            -> { order(flags_count: :desc, updated_at: :desc) }
  scope :sort_by_archival_date,    -> { archived.sort_by_confidence_score }
  scope :sort_by_recommendations,  -> { order(cached_votes_up: :desc) }
  scope :archived,                 -> { where("proposals.created_at <= ?", Setting["months_to_archive_proposals"].to_i.months.ago) }
  scope :not_archived,             -> { where("proposals.created_at > ?", Setting["months_to_archive_proposals"].to_i.months.ago) }
  scope :last_week,                -> { where("proposals.created_at >= ?", 7.days.ago)}
  scope :retired,                  -> { where.not(retired_at: nil) }
  scope :not_retired,              -> { where(retired_at: nil) }
  scope :successful,               -> { where("cached_votes_up >= ?", Proposal.votes_needed_for_success) }
  scope :unsuccessful,             -> { where("cached_votes_up < ?", Proposal.votes_needed_for_success) }
  scope :public_for_api,           -> { all }
  scope :not_supported_by_user,    ->(user) { where.not(id: user.find_voted_items(votable_type: "Proposal").compact.map(&:id)) }
  scope :is_proposal, -> { where(is_proposal: true) }
  scope :is_legislation_proposal, -> { where(is_proposal: false) }

  def self.title_max_length
    180
  end

  def categories_is_visible?
    if self.is_proposal || Setting.to_bool('legislation_proposals_categories_is_visible')
      return true
    else
      return false
    end
  end

  def group_is_visible?
    if self.is_proposal || Setting.to_bool('legislation_proposals_group_is_visible')
      return true
    else
      return false
    end
  end

  def url
    if self.is_proposal
      proposal_path(self)
    else
      legislation_proposal_path(self)
    end
  end

  def self.recommendations(user)
    tagged_with(user.interests, any: true)
      .where("author_id != ?", user.id)
      .unsuccessful
      .not_followed_by_user(user)
      .not_archived
      .not_supported_by_user(user)
  end

  def self.not_followed_by_user(user)
    where.not(id: followed_by_user(user).pluck(:id))
  end

  def to_param
    "#{id}-#{title}".parameterize
  end

  def searchable_values
    { title              => 'A',
      question           => 'B',
      author.username    => 'B',
      tag_list.join(' ') => 'B',
      geozone.try(:name) => 'B',
      summary            => 'C',
      description        => 'D'
    }
  end

  def self.search(terms)
    by_code = search_by_code(terms.strip)
    by_comments = search_by_comments(terms.strip).pluck(:id)
    if by_code.present?
      where(id: by_comments + by_code.pluck(:id)).uniq
    else
      pg_ids = pg_search(terms).pluck(:id)
      where(id: by_comments + pg_ids).uniq
    end
  end

  def self.search_by_code(terms)
    matched_code = match_code(terms)
    results = where(id: matched_code[1]) if matched_code
    return results if results.present? && results.first.code == terms
  end

  def self.search_by_comments(terms)
    joins(:comments).where("comments.body ILIKE ?", "%#{terms}%").uniq
  end

  def self.match_code(terms)
    /\A#{Setting["proposal_code_prefix"]}-\d\d\d\d-\d\d-(\d*)\z/.match(terms)
  end

  def self.for_summary
    summary = {}
    categories = ActsAsTaggableOn::Tag.category_names.sort
    geozones   = Geozone.names.sort

    groups = categories + geozones
    groups.each do |group|
      summary[group] = search(group).last_week.sort_by_confidence_score.limit(3)
    end
    summary
  end

  def total_votes
    cached_votes_up
  end

  def voters
    User.active.where(id: votes_for.voters)
  end

  def editable?
    total_votes <= Setting["max_votes_for_proposal_edit"].to_i
  end

  def editable_by?(user)
    author_id == user.id && editable?
  end

  def votable_by?(user)
    user && user.level_two_or_three_verified?
  end

  def self.in_active_period?
    proposal_date_from = Setting.exists?(key: "proposals_start_date") ? Setting.find_by(key: "proposals_start_date").value : nil
    proposal_date_to = Setting.exists?(key: "proposals_end_date") ? Setting.find_by(key: "proposals_end_date").value : nil
    (proposal_date_from.nil? || Date.today >= proposal_date_from.to_date) && (proposal_date_to.nil? || Date.today <= proposal_date_to.to_date)
  rescue
    true
  end

  def self.legislation_in_active_period?
    proposal_date_from = Setting.exists?(key: "legislation_proposals_start_date") ? Setting.find_by(key: "legislation_proposals_start_date").value : nil
    proposal_date_to = Setting.exists?(key: "legislation_proposals_end_date") ? Setting.find_by(key: "legislation_proposals_end_date").value : nil
    (proposal_date_from.nil? || Date.today >= proposal_date_from.to_date) && (proposal_date_to.nil? || Date.today <= proposal_date_to.to_date)
  rescue
    true
  end

  def retired?
    retired_at.present?
  end

  def permit_delete_or_edit?
    !(comments.count > 0 || total_votes > 0)
  end

  def register_vote(user, vote_value)
    if votable_by?(user) && !archived?
      vote_by(voter: user, vote: vote_value)
    end
  end

  def code
    "#{Setting['proposal_code_prefix']}-#{created_at.strftime('%Y-%m')}-#{id}"
  end

  def after_commented
    save # updates the hot_score because there is a before_save
  end

  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(created_at,
                                               total_votes,
                                               total_votes,
                                               comments_count)
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(total_votes, total_votes)
  end

  def after_hide
    tags.each{ |t| t.decrement_custom_counter_for('Proposal') }
  end

  def after_restore
    tags.each{ |t| t.increment_custom_counter_for('Proposal') }
  end

  def self.votes_needed_for_success
    Setting['votes_for_proposal_success'].to_i
  end

  def successful?
    total_votes >= Proposal.votes_needed_for_success
  end

  def archived?
    created_at <= Setting["months_to_archive_proposals"].to_i.months.ago
  end

  def notifications
    proposal_notifications
  end

  def users_to_notify
    (voters + followers).uniq
  end

  def self.proposals_orders(user, is_proposal=true)
    if !is_proposal
      orders = %w{hot_score relevance}
    else
      orders = %w{hot_score created_at relevance}
    end
    orders
  end

  def self.can_manage?(user, is_proposal)
    if is_proposal
      if Setting.exists?(key: "proposals_require_admin")
        return !["1","true"].include?(Setting[:proposals_require_admin]) || user.try(:administrator?) || user.try(:moderator?)
      end
    else
      if Setting.exists?(key: "legislation_proposals_require_admin")
        return !["1","true"].include?(Setting[:legislation_proposals_require_admin]) || user.try(:administrator?) || user.try(:moderator?)
      end
    end
    true
  end

  def aproved_comments_count
    comments.where(status: Comment::STATUS[:aproved]).count
  end

end
