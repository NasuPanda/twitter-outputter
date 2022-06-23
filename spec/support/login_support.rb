module LoginSupport
  # ユーザーをログインさせる
  def sign_in_as(user = nil)
    uid = user ? user.authentication.uid : 'random_id'
    twitter_valid_mock(uid)
    create_new_session
  end
  # ログインでも新規登録でもやることは変わらないため
  alias_method :sign_up, :sign_in_as

  def sign_in_with_denied_authentication
    twitter_invalid_mock
    create_new_session
  end
  alias_method :sign_up_with_denied_authentication, :sign_in_with_denied_authentication

  # ログインしているかどうか判定する
  def is_logged_in?
    !cookies[:user_id].blank?
  end

  private
    def create_new_session
      case
      # visit: システムスペックのとき
      when respond_to?(:visit)
        visit root_path
        click_on "Twitterでログイン"
      # get: リクエストスペックのとき
      when respond_to?(:get)
        get "/auth/twitter/callback"
      # それ以外ならエラー
      else
        raise NotImplementedError.new
      end
    end

    def twitter_valid_mock(uid)
      OmniAuth.config.add_mock(
        :twitter,
        uid: uid,
        credentials: {
          token: 'access_token',
          secret: 'access_token_secret'
        }
      )
    end

    def twitter_invalid_mock
      OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
    end
end

RSpec.configure do |config|
  config.include LoginSupport
end