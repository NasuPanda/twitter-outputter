class RenameIsAddedColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :tags, :is_tagged, :is_tagged
  end
end
