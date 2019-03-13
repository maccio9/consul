class AddLogtextToUser < ActiveRecord::Migration
  def change
    add_column :users, :log_text, :text
  end
end
