class Tags::TaggedController < ApplicationController
  before_action :redirect_to_root_if_not_logged_in

  def create
    tag = current_user.tags.find(tagged_params[:id])
    # 既にtaggedの場合は失敗する
    if tag.is_tagged?
      @error_messages = ['既に使用されているタグです。同じタグを使用することは出来ません。']
      return
    end
    @error_messages =  tag.update(is_tagged: true) ? [] :  error_messages_with_prefix(tag, 'タグのセットに失敗しました。')
    @tag = tag
  end

  def destroy
    tag = current_user.tags.find(tagged_params[:id])
    unless tag.is_tagged?
      @error_messages =  error_messages_with_prefix(tag, 'タグのセット解除に失敗しました。')
      return
    end
    @error_messages = tag.update(is_tagged: false) ? [] :  error_messages_with_prefix(tag, 'タグのセット解除に失敗しました。')
    @tag = tag
  end

  private
    def tagged_params
      params.permit(:id)
    end
end
