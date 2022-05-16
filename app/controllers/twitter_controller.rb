class TwitterController < ApplicationController
  before_action :set_twitter_client

  def update
    @client.update("TwitterAPIから投稿(削除予定)")
  end

  private
    def set_twitter_client
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.credentials.twitter[:client_id]
        config.consumer_secret     = Rails.application.credentials.twitter[:client_secret]
        config.access_token        = session[:access_token]
        config.access_token_secret = session[:access_secret]
      end
    end
end