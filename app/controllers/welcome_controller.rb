class WelcomeController < ApplicationController
  def index
    cookies.permanent[:test] = "test value"
  end

  # FIXME 消す
  def show
    puts "create notice * * * * * * * * * *"
    external_user_id = cookies[:external_user_id]
    CreateNotification.call(
      contents: { 'en' => 'Post created!', 'ja' => '投稿が作成されました！' },
      type: 'posts#create',
      external_user_id: external_user_id
    )
  end
end
