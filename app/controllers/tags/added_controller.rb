class Tags::AddedController < ApplicationController
  def create
    tag = current_user.tags.find(create_params[:tag_id])
    # 既にaddedの場合は失敗する
    if tag.is_added?
      @status = '既に使用されているタグです。同じタグを使用することは出来ません。'
      return
    end
    @status =  tag.update(is_added: true) ? 'success' : 'failure'
    @tag = tag
  end

  def destroy
    tag = current_user.tags.find(destroy_params[:id])
    unless tag.is_added?
      @status = 'failure'
      return
    end
    @status = tag.update(is_added: false) ? 'success' : 'failure'
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
