class Tags::TaggedController < ApplicationController
  def create
    tag = current_user.tags.find(create_params[:tag_id])
    # 既にtaggedの場合は失敗する
    if tag.is_tagged?
      @error_messages = ['既に使用されているタグです。同じタグを使用することは出来ません。']
      return
    end
    @error_messages =  tag.update(is_tagged: true) ? [] :  error_messages_with_prefix(tag, 'タグのセットに失敗しました。')
    @tag = tag
  end

  def destroy
    tag = current_user.tags.find(destroy_params[:id])
    unless tag.is_tagged?
      @error_messages =  error_messages_with_prefix(tag)
      return
    end
    @error_messages = tag.update(is_tagged: false) ? [] :  error_messages_with_prefix(tag, 'タグのセット解除に失敗しました。')
    @tag = tag
  end

  private
    def create_params
      params.permit(:tag_id)
    end

    def destroy_params
      params.permit(:id)
    end
end
