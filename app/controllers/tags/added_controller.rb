class Tags::AddedController < ApplicationController
  def create
    tag = current_user.tags.find(tag_params[:tag_id])
    # 既にaddedの場合は失敗する
    if tag.is_added?
      @status = '既に使用されているタグです。同じタグを使用することは出来ません。'
      return
    end
    @status =  tag.update(is_added: true) ? 'success' : 'failure'
    @tag = tag
  end

  def destroy
  end

  private
    def tag_params
      params.permit(:tag_id)
    end
end
