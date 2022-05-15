module LoginSupport

  # ユーザーをログインさせる
  def sign_in_as(user)
    # モックの作成
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(
      user.provider,
      uid: user.uid
    )
    case
    # respond_to? は 対象のインスタンスがメソッドを持っている場合にtrueを返す
    # visit: システムスペックのとき
    when respond_to?(:visit)
      visit root_path
      click_on "Twitterでログイン"
    # get: リクエストスペックのとき
    when respond_to?(:get)
      get "/auth/twitter/callback"
    # else: それ以外
    else
      raise NotImprementedError.new
    end
  end

  # ログインしているかどうか判定する
  def is_logged_in?
    !session[:user_id].nil?
  end
end

RSpec.configure do |config|
  config.include LoginSupport
end