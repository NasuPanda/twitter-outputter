class AddIndexToUsers < ActiveRecord::Migration[6.0]
  def change
    add_index :tags, [:name, :user_id], unique: true
    add_index :posts, [:content, :user_id], unique: true
  end
end
