module ApplicationHelper
  def current_user
    @user ||= User.find(cookies.signed[:user_id])
  end

  def logged_in?
    !!cookies.signed[:user_id]
  end
end
