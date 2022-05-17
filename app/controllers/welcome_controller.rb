class WelcomeController < ApplicationController
  def index
  end

  # FIXME 消す
  def show
    puts "create notice * * * * * * * * * *"
    CreateNotification.call(
      contents: { 'en' => 'Post created!', 'ja' => '投稿が作成されました！' },
      type: 'posts#create'
    )
  end
end
