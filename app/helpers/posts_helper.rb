module PostsHelper
  include Twitter::TwitterText::Validation
  MAX_TWEET_LENGTH = 140
  CARD_TEXT_CLASS = 'card-text'

  # Postカードに表示するテキストを配列として返す
  def post_card_texts(post)
    # 改行文字を指すメタ文字を使用して分割
    delimited_contents = post.content.split(/\R/)
    opening_tag, closing_tag = card_text_p_tag

    delimited_contents.map do |content|
      # 例: <p class="card-text">text</p>
      opening_tag + content + closing_tag
    end
  end

  # HTMLにおけるPostのidを返す
  def post_id(post)
    "post-#{post.id}"
  end

  # twitter投稿テキストのカウントダウン(残り入力可能文字数)を返す
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

    # card-textを指すクラスを持つpタグ
    def card_text_p_tag
      return "<p class='#{CARD_TEXT_CLASS}'>".html_safe, "</p>".html_safe
    end
end
