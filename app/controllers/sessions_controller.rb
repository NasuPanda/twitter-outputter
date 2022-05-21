class SessionsController < ApplicationController
  def create
    if auth_params[:denied].present?
      redirect_to root_path, notice: "ログインをキャンセルしました"
      return
    end

    auth_hash = request.env['omniauth.auth']
    # TODO ロジック分離
    # User.find_or_create_by_auth_hash!にする。
    unless user = get_user_from_auth(auth_hash[:uid])
      user = User.create
      user.create_authentication_from_auth_hash!(auth_hash)
    end

    # TODO ロジック分離
    # User.set...にする
    if cookies.signed[:external_user_id].blank?
      set_external_user_id_to_cookies(user)
    end

    session[:user_id] = user.id
    redirect_to root_path, notice: 'ログインしました'
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'ログアウトしました'
  end

  private
    def auth_params
      params.permit(:denied)
    end

    # TODO 関連レコードの検索(scopeにより実装)と置換する
    def get_user_from_auth(uid)
      return unless authentication = Authentication.find_by(uid: uid)
      user = authentication.user
    end

    # 分離する(上参考)
    def set_external_user_id_to_cookies(user)
      unless external_user_id = user.external_user_id
        external_user_id = SecureRandom.uuid
        user.set_external_user_id(external_user_id)
      end
      cookies.signed.permanent[:external_user_id] = external_user_id
    end
end
