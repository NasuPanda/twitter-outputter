class AddAddedToTags < ActiveRecord::Migration[6.0]
  def change
    add_column :tags, :is_added, :boolean, default: false, null: false
  end
end
