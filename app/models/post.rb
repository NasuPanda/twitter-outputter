class Post < ApplicationRecord
  include OrderableByTimestamp              # タイムタンプで並び替えるため
  include Twitter::TwitterText::Validation  # Twitterのバリデーションのため
  enum status: { draft: 0, reserved: 1, published: 2 }

  belongs_to :user

  validates :content, presence: true, uniqueness: { scope: :user_id }
  validate :content_shold_be_valid_twitter_text, if: Proc.new { |post| post.content.present? }
  validate :post_at_cannot_be_blank_if_reserved_or_published

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
      if reserved? || published?
        if post_at.blank?
          errors.add(:post_at, '投稿予約状態または投稿済のPostはpost_atカラムを持つ必要があります')
        end
      end
    end
end
