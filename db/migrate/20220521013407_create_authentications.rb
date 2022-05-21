class CreateAuthentications < ActiveRecord::Migration[6.0]
  def change
    create_table :authentications do |t|
      t.integer :user_id, nll: false
      t.string :uid, nll: false
      t.string :access_token, nll: false
      t.string :access_token_secret, nll: false

      t.timestamps
    end

    add_index :authentications, :user_id
  end
end
