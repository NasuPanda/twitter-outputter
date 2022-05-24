class SessionsController < ApplicationController
  def create
    user = User.find_or_create_by_auth_hash(auth_hash)

    if cookies[:external_user_id].blank?
      external_user_id = user.get_or_create_external_user_id
      cookies.permanent[:external_user_id] = external_user_id
    end

    cookies.permanent.signed[:user_id] = user.id
    redirect_to root_url, notice: 'ログインしました'
  end

  def destroy
    cookies.delete(:user_id)
    redirect_to root_url, notice: 'ログアウトしました'
  end

  def failure
    redirect_to root_url, notice: 'ログインをキャンセルしました'
  end

  private
    def auth_params
      params.permit(:denied)
    end

    def auth_hash
      request.env['omniauth.auth']
    end
end
