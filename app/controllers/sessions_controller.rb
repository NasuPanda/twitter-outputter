class SessionsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']

    user = User.find_or_create_by_auth_hash!(auth_hash)

    if cookies.signed[:external_user_id].blank?
      external_user_id = user.find_or_create_external_user_id
      cookies.signed.permanent[:external_user_id] = external_user_id
    end

    session[:user_id] = user.id
    redirect_to root_url, notice: 'ログインしました'
  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'ログアウトしました'
  end

  def failure
    redirect_to root_url, notice: 'ログインをキャンセルしました'
  end

  private
    def auth_params
      params.permit(:denied)
    end
end
