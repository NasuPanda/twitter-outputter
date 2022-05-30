class RemoveIsPostedFromPosts < ActiveRecord::Migration[6.0]
  def change
    remove_column :posts, :is_posted, :boolean
  end
end
