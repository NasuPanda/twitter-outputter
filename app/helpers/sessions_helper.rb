module SessionsHelper
  # 現在ログインしているユーザを返す
  def current_user
    @user ||= User.find(cookies.signed[:user_id])
  end

  def logged_in?
    !!cookies.signed[:user_id]
  end

  def current_user?(user)
    user && user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end