class AddExternalUserIdToUsers < ActiveRecord::Migration[6.0]
  def change
    # プッシュ通知用のIDなので、NOTNULL制約は付与しない
    add_column :users, :external_user_id, :string
    add_index :users, :external_user_id, unique: true
  end
end
