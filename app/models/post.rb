class Post < ApplicationRecord
  include OrderableByTimestamp              # タイムタンプで並び替えるため
  include Twitter::TwitterText::Validation  # Twitterのバリデーションのため
  enum status: { draft: 0, scheduled: 1, published: 2 }

  belongs_to :user

  validates :content, presence: true, uniqueness: { scope: :user_id }
  validate :content_shold_be_valid_twitter_text, if: Proc.new { |post| post.content.present? }
  validate :post_at_cannot_be_blank_if_scheduled_or_published
  validate :post_at_should_be_on_or_after_now, if: Proc.new { |post| post.scheduled? || post.draft? }
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
    self.status = :draft
  end

  # 投稿済に変更する(post_atを付与)
  def to_published
    self.status = :published
    self.post_at = Time.current
  end

  # 予約済に変更する
  def to_scheduled
    self.status = :scheduled
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
end
