class Post < ApplicationRecord
  include OrderableByTimestamp              # タイムタンプで並び替えるため
  include Twitter::TwitterText::Validation  # Twitterのバリデーションのため
  enum status: { draft: 0, reserved: 1, published: 2 }

  belongs_to :user

  validates :content, presence: true, uniqueness: { scope: :user_id }
  validate :content_shold_be_valid_twitter_text, if: Proc.new { |post| post.content.present? }
  validate :post_at_cannot_be_blank_if_reserved_or_published

  # タグのリストを受け取りcontentに追加する
  def add_tags_to_content(tags)
    return if tags.blank?

    tags.each do |tag|
      # タグの前には半角スペースを入れること
      self.content += ' '
      self.content += tag.name
    end
  end

  # 投稿済に変更する
  def to_published
    self.status = :published
    self.post_at = Time.current
  end

  # 予約済に変更する
  def to_reserved(post_at)
    self.status = :reserved
    self.post_at = post_at
    post_at_should_be_on_or_after_now
  end

  private
    # バリデーション : contentが有効なtwitter-textであること
    def content_shold_be_valid_twitter_text
      # NOTE: valid_tweetは非推奨なのでparse_tweetを使う
      parse_result = parse_tweet(self.content)
      unless parse_result[:valid]
        self.errors[:content] << '投稿内容が無効です'
      end
    end

    # バリデーション : 投稿予約状態または投稿済のとき、post_atは存在しなければならない
    def post_at_cannot_be_blank_if_reserved_or_published
      if (reserved? || published?) && post_at.blank?
        errors.add(:post_at, '投稿予約状態または投稿済のPostはpost_atカラムを持つ必要があります')
      end
    end

    # バリデーション : post_atが現在、またはそれ以降であること
    def post_at_should_be_on_or_after_now
      if post_at <= Time.current
        errors.add(:post_at, 'は現在よりも後に設定してください')
      end
    end
end
