class AddAddedToTags < ActiveRecord::Migration[6.0]
  def change
    add_column :tags, :is_tagged, :boolean, default: false, null: false
  end
end
