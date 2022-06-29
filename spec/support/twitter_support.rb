module TwitterSupport
  # TwitterAPIをモック化
  def twitter_mock_from_instance(user)
    twitter_client_mock = double('TwitterClient')
    allow(twitter_client_mock).to receive(:update!).and_return('tweet')
    allow(twitter_client_mock).to receive(:update_with_media).and_return('tweet_with_media')
    allow(twitter_client_mock).to receive(:user_timeline).and_return(['tweet'])
    allow(user).to receive(:twitter_client).and_return(twitter_client_mock)
    allow(user).to receive(:post_tweet_without_media).and_return('tweet_without_media')
    allow(user).to receive(:post_tweet_with_media).and_return('tweet_with_media')
  end

  # TwitterAPIをモック化
  # HACK: user.twitter_clientがprivateのため?オーバーライド出来なかった。allow_any_instance_ofで一時的に対処。
  # userスペックで呼び出す場合はオーバーライド出来るのが謎。
  def twitter_mock
    twitter_client_mock = double('TwitterClient')
    allow(twitter_client_mock).to receive(:update!).and_return('tweet')
    allow(twitter_client_mock).to receive(:update_with_media).and_return('tweet_with_media')
    allow(twitter_client_mock).to receive(:user_timeline).and_return(['tweet'])
    allow_any_instance_of(User).to receive(:twitter_client).and_return(twitter_client_mock)
  end
end

RSpec.configure do |config|
  config.include TwitterSupport
end
