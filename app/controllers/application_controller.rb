class ApplicationController < ActionController::Base
  include SessionsHelper

  helper_method %i[current_user logged_in?]

  private

    def redirect_to_root_if_not_logged_in
      unless logged_in?
        redirect_to root_url, notice: 'ログインしてください'
      end
    end

    # モデルの持つエラーメッセージにprefixを付けて返す(非破壊)
    def error_messages_with_prefix(model, prefix)
      error_messages = model.errors.full_messages.dup
      error_messages.prepend(prefix)
    end
end
