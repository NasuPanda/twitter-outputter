class AddAccessTokenToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :access_token, :string, null: false
    add_column :users, :access_token_secret, :string, null: false
  end
end
