class ApplicationController < ActionController::Base
  helper_method :logged_in?

  private

    # 現在ログインしているユーザを返す
    def current_user
      @user ||= User.find(session[:user_id])
    end

    def logged_in?
      !!session[:user_id]
    end
end
