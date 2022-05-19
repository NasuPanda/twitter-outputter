class SessionsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    user = User.find_or_create_from_auth_hash!(auth_hash)
    # FIXME authentication関連の処理を切り出す
    # FIXME access tokenを暗号化しつつDBへ保存
    # FIXME access tokenを永続化する(RememberMe)
    access_token = auth_hash.credentials.token
    access_secret = auth_hash.credentials.secret

    if cookies.permanent[:external_user_id].nil?
      # if not external_user_id = user.external_user_id
      external_user_id = SecureRandom.uuid
        # TODO DBへ保存
      # end
      cookies.permanent[:external_user_id] = external_user_id
    end
    session[:user_id] = user.id
    session[:access_token] = access_token
    session[:access_secret] = access_secret
    redirect_to root_path, notice: 'ログインしました'
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'ログアウトしました'
  end
end
