module PostsHelper
  include Twitter::TwitterText::Validation
  MAX_TWEET_LENGTH = 140

  def post_id(post)
    "post-#{post.id}"
  end

  def count_down_twitter_text(text)
    # NOTE: valid_tweetは非推奨なのでparse_tweetを使う
    parse_result = parse_tweet(text)
    weighted_length = parse_result[:weighted_length]
    return MAX_TWEET_LENGTH - to_ja(weighted_length)
  end

  private

    # weithed_lengthを日本版に合わせて変換する
    def to_ja(weighted_length)
      return weighted_length.to_f / 2
    end
end
