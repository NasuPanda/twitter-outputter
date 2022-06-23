class ApplicationController < ActionController::Base
  include ApplicationHelper
  include SessionsHelper

  # ApplicationHelperのメソッド
  helper_method %i[error_messages_with_prefix]
  # SessionsHelperのメソッド
  helper_method %i[current_user logged_in?]

  private

    def redirect_to_root_if_not_logged_in
      unless logged_in?
        redirect_to root_url, alert: 'ログインしてください'
      end
    end
end
