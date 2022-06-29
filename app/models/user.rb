class User < ApplicationRecord
  scope :find_authentication_uid, -> (uid) {
    joins(:authentication).merge(Authentication.uid_is(uid))
  }
  has_one :authentication, dependent: :destroy
  has_one :notification_setting, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :tags, dependent: :destroy
  accepts_nested_attributes_for :authentication
  # Userは必ずNotificationSettingを持つ
  after_create :create_notification_setting, if: Proc.new { notification_setting.present? }

  def get_or_create_external_user_id
    return self.external_user_id if self.external_user_id
    external_user_id = SecureRandom.uuid
    self.update_attribute(:external_user_id, external_user_id)
    return external_user_id
  end

  # status: draft のPostを取得
  def drafts
    find_posts_by_status(:draft)
  end

  # status: draft のPostを更新日時降順で取得
  def drafts_by_recently_updated
    drafts.by_recently_updated
  end

  # status: published のPostを取得
  def published_posts
    find_posts_by_status(:published)
  end

  # status: published のPostを投稿日時降順で取得
  def published_posts_by_recently_posted
    published_posts.by_recently_posted
  end

  # status: scheduled のPostを取得
  def scheduled_posts
    find_posts_by_status(:scheduled)
  end

  # status: scheduled のPostを投稿予定日順で取得
  def scheduled_posts_by_recently_posting
    scheduled_posts.by_recently_posted
  end

  # is_taggedがtrueのtagを取得する
  def tagged_tags
    tags.where(is_tagged: true)
  end

  # ツイートする
  def post_tweet(post)
    # 画像が添付されていれば画像付きツイートを実行
    if post.images.attached?
      post_tweet_with_media(post)
    # 画像が添付されていなければ通常のツイート
    else
      post_tweet_without_media(post)
    end
  end

  # 指定期間内にツイートしているか判定する
  def most_recent_tweet
    # https://www.rubydoc.info/gems/twitter/5.16.0/Twitter/REST/Timelines#user_timeline-instance_method
    tweets = twitter_client.user_timeline(
      self.authentication.uid.to_i,
      options = { count: 1 }
    )
    return if tweets.empty?
    tweets[0]
  end

  def self.find_or_create_by_auth_hash(auth_hash)
    user = self.find_by_auth_hash(auth_hash)
    if user
      # 認証解除→再登録時にトークンが無効になるため、ログインし直すたびに更新する
      user.authentication.update!(
        access_token: auth_hash.credentials.token,
        access_token_secret: auth_hash.credentials.secret
      )
    else
      user = self.create_by_auth_hash(auth_hash)
    end
    return user
  end

  private

    # statusを元にPostを探す
    def find_posts_by_status(status)
      posts.where(status: status)
    end

    # Twitter-OmniAuthから受け取ったハッシュを元にユーザを探す
    def self.find_by_auth_hash(auth_hash)
      uid = auth_hash[:uid]
      user = self.find_authentication_uid(uid).first
    end

    # Twitter-OmniAuthから受け取ったハッシュを元にユーザを作る
    def self.create_by_auth_hash(auth_hash)
      uid = auth_hash[:uid]
      user = self.new()
      user.build_authentication(
        uid: uid,
        access_token: auth_hash.credentials.token,
        access_token_secret: auth_hash.credentials.secret
      )
      user.save
      return user
    end

    # TwitterAPIを叩くためのクライアント
    # Userに依存しているのでUserに定義している
    def twitter_client
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.credentials.twitter[:client_id]
        config.consumer_secret     = Rails.application.credentials.twitter[:client_secret]
        config.access_token        = self.authentication.decrypted_access_token
        config.access_token_secret = self.authentication.decrypted_access_token_secret
      end
    end

    # 通常の投稿
    def post_tweet_without_media(post)
      twitter_client.update!(post.content)
    end

    # 画像付き投稿
    def post_tweet_with_media(post)
      download_all_attachments(post.images) do |images|
        twitter_client.update_with_media(post.content, images)
      end
    end

  # 全ての画像をダウンロードする
  # NOTE: 実行したい処理のブロックを引数に取る
  # ActiveStorage::Attachment.open(=blob.open)でTempfileを生成。
  # このTempfileはブロックを抜けた段階で削除されてしまう。 参考: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-open
  # Tempfileを一括ダウンロード・使用したい場合、ブロックからブロックを呼び出す(再帰的に)等してブロック内の処理を終了させないようにする必要がある。
  def download_all_attachments(attachments, downloaded_files = [], &block)
    # attachmentsが空ならブロックにdownloaded_filesを渡して実行
    if attachments.empty?
      yield downloaded_files
      return
    end

    # downloaded_filesにTempfileが代入されていき、attachmentsから要素が取り出されていく。
    attachments.first.open do |file|
      downloaded_files << file
      send(__method__, attachments[1..attachments.length - 1], downloaded_files, &block)
    end
  end
end
