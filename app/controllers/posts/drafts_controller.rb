class Posts::DraftsController < ApplicationController
  def index
    @drafts = current_user.drafts
  end

  def new
    @draft = current_user.posts.build
  end

  # NOTE: status はデフォルトで draftのため指定不要
  def create
    @draft = current_user.posts.build(draft_params)
    if @draft.save
      respond_to do |format|
        format.html { redirect_to root_url, notice: '下書きの保存に成功しました' }
        format.js { @status = 'success' }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_url, alert: '下書きの保存に失敗しました' }
        format.js { @status = 'failure' }
      end
    end
  end

  def edit
    @draft = current_user.drafts.find(params[:id])
  end

  def update
    @draft = current_user.drafts.find(parmas[:id])
    @status = @draft.update(draft_params) ? 'success' : 'failure'
  end

  # NOTE : 下書きから削除 → 予約投稿 or 投稿済 へ
  def destroy
  end

  private

    def draft_params
      params.require(:post).permit(:content)
    end
end
