class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      # OAuth認証で使用するプロバイダ名
      t.string :provider, null: false
      # provider毎に与えられるユーザ識別用の文字列
      t.string :uid,      null: false

      t.timestamps
    end

    add_index :users, %i[provider uid], unique: true
  end
end
