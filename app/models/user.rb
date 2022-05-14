class User < ApplicationRecord
  def self.find_or_create_from_auth_hash!(auth_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]
    # TODO ログイン中のユーザーの情報を追加する
    # nickname = auth_hash[:info][:nickname]

    User.find_or_create_by!(provider: provider, uid: uid)
    # User.find_or_create_by!(provider: provider, uid: uid) do |user|
    #   user.name = nickname
    # end
  end
end
