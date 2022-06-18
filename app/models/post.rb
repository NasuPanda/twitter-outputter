class Post < ApplicationRecord
  class PublishedToDraftError < StandardError; end
  class PublishedToScheduledError < StandardError; end
  include OrderableByTimestamp              # タイムタンプで並び替えるため
  include Twitter::TwitterText::Validation  # Twitterのバリデーションのため
  enum status: { draft: 0, scheduled: 1, published: 2 }

  has_one :scheduled_post_job, dependent: :destroy, class_name: 'ScheduledPostJob'
  belongs_to :user

  validates :content, presence: true, uniqueness: { scope: :user_id }
  validate :content_shold_be_valid_twitter_text, if: Proc.new { |post| post.content.present? }
  validate :post_at_cannot_be_blank_if_scheduled_or_published
  validate :post_at_should_be_on_or_after_now, if: Proc.new { |post| post.scheduled? }
  validate :post_at_should_be_within_a_year, if: Proc.new { |post| post.scheduled? }

  # タグのリストを受け取りcontentに追加する
  def add_tags_to_content(tags)
    return if tags.blank?

    tags.each do |tag|
      # タグの前には半角スペースを入れること
      self.content += ' '
      self.content += tag.name
    end
  end

  # to_**! を使うと保存されてしまうため使わない
  # 下書きに変更する
  def to_draft
    raise PublishedToDraftError, '公開済みの投稿を下書きに変更しようとしています' if self.published?
    self.status = :draft
  end

  # 予約済に変更する
  def to_scheduled
    raise PublishedToScheduledError, '公開済みの投稿を予約投稿に変更しようとしています' if self.published?
    self.status = :scheduled
  end

  # 投稿済に変更する(post_atを付与)
  def to_published
    self.status = :published
    self.post_at = Time.current
  end

  # ジョブをセットする
  def set_scheduled_post_job
    job = perform_later_scheduled_post_job
    self.create_scheduled_post_job(job_id: job.provider_job_id)
  end

  # 予約ツイートの更新(ジョブの更新)
  def update_scheduled_tweet
    return unless self.scheduled_post_job

    job = perform_later_scheduled_post_job
    # statusも更新しておく
    # 投稿失敗 → status: failure → 修正して再度予約投稿した場合のため
    self.scheduled_post_job.update!(job_id: job.provider_job_id, status: 'scheduled')
  end

  # 予約ツイートのキャンセル(ジョブの削除)
  def cancel_scheduled_tweet
    return unless self.scheduled_post_job
    self.scheduled_post_job.destroy!
  end

  # 予約ツイートが成功したかどうか判定
  def scheduled_tweet_failure?
    return unless self.scheduled_post_job

    self.scheduled_post_job.failure?
  end

  private
    # バリデーション : contentが有効なtwitter-textであること
    def content_shold_be_valid_twitter_text
      # NOTE: valid_tweetは非推奨なのでparse_tweetを使う
      parse_result = parse_tweet(self.content)
      unless parse_result[:valid]
        self.errors[:content] << 'が無効です。'
      end
    end

    # バリデーション(予約投稿 or 投稿済のとき) : post_atは存在しなければならない
    def post_at_cannot_be_blank_if_scheduled_or_published
      if (scheduled? || published?) && post_at.blank?
        errors[:post_at] << 'が必要です。'
      end
    end

    # バリデーション(予約投稿のとき) : post_atが現在、またはそれ以降であること
    def post_at_should_be_on_or_after_now
      return if post_at.nil?

      if post_at <= Time.current
        errors[:post_at] << 'は現在よりも後に設定してください。'
      end
    end

    # バリデーション(予約投稿のとき) : post_atが1年以内であること
    def post_at_should_be_within_a_year
      return if post_at.nil?

      if post_at >= 1.years.from_now
        errors[:post_at] << 'は1年以内に設定してください。'
      end
    end

    # 投稿予約ジョブをセット
    def perform_later_scheduled_post_job
      ReservePostJob.set(wait_until: self.post_at).perform_later(
        self.user, self.id, self.updated_at
      )
    end
end
