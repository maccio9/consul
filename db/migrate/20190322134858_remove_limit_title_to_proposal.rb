class RemoveLimitTitleToProposal < ActiveRecord::Migration
  def up
    change_column :proposals, :title, :string, limit: nil
  end

  def down
    change_column :proposals, :title, :string, limit: 80
  end
end
