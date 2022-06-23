class Pages::SettingsController < ApplicationController
  before_action :redirect_to_root_if_not_logged_in

  def show
    @setting = current_user.notification_setting
  end

  def edit
    @setting = current_user.notification_setting
  end

  def update
    @setting = current_user.notification_setting
    if @setting.update(setting_params)
      @setting.send("#{@setting.job_action}_check_tweet_job")

      respond_to do |format|
        format.html { redirect_to setting_url, notice: '設定の更新に成功しました' }
        format.js { @error_messages = [] }
      end
    else
      respond_to do |format|
        format.html { redirect_to setting_url, notice: '設定の更新に失敗しました' }
        format.js { @error_messages = error_messages_with_prefix(@setting, '設定の更新に失敗しました。') }
      end
    end
  end

  private

    def setting_params
      params.require(:notification_setting).permit(:can_notify, :notify_at, :interval_to_check)
    end
end
