class ApplicationController < ActionController::Base
  include SessionsHelper

  helper_method %i[current_user logged_in?]

  private

    def redirect_to_root_if_not_logged_in
      unless logged_in?
        redirect_to root_url, notice: 'ログインしてください'
      end
    end
end
