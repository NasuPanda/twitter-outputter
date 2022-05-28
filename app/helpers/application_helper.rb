module ApplicationHelper
  def current_user
    @user ||= User.find(cookies.signed[:user_id])
  end
end
