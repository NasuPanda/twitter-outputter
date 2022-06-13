module TwitterSupport
  # Twitter::Clientのモックを作る
  def build_twitter_mock(user)
    twitter_client_mock = double('TwitterClient')
    allow(twitter_client_mock).to receive(:update!).and_return("tweet")
    allow(user).to receive(:twitter_client).and_return(twitter_client_mock)
  end
end

RSpec.configure do |config|
  config.include TwitterSupport
end