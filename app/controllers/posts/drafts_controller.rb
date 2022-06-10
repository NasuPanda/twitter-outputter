class Posts::DraftsController < ApplicationController
  def index
    # indexの場合はdraftsを更新日時の降順で取得する
    @drafts = current_user.drafts_by_recently_updated.
      page(params[:page]).per(10)
  end

  def new
    @draft = current_user.posts.build
  end

  # NOTE: status はデフォルトで draftのため指定不要
  def create
    @draft = current_user.posts.build(draft_params)
    # NOTE: 新規作成の場合, タグ付けされたタグをcontentに追加しておく
    @draft.add_tags_to_content(current_user.tagged_tags)
    if @draft.save
      respond_to do |format|
        format.html { redirect_to root_url, notice: '下書きの保存に成功しました。' }
        format.js { @error_messages = [] }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_url, alert: '下書きの保存に失敗しました。' }
        format.js { @error_messages = error_messages_with_prefix(@draft, '下書きの保存に失敗しました。') }
      end
    end
  end

  def edit
    @draft = current_user.drafts.find(params[:id])
  end

  def update
    @draft = current_user.drafts.find(params[:id])
    if @draft.update(draft_params)
      respond_to do |format|
        format.html { redirect_to drafts_url, notice: '下書きの更新に成功しました' }
        format.js { @error_messages = [] }
      end
    else
      respond_to do |format|
        format.html { redirect_to drafts_url, notice: '下書きの更新に失敗しました' }
        format.js { @error_messages = error_messages_with_prefix(@draft, '下書きの更新に失敗しました。') }
      end
    end
  end

  # NOTE : 下書きから削除 → 予約投稿 or 投稿済 へ
  def destroy
    @draft = current_user.drafts.find(params[:id])
    # TODO 予約投稿へ移動する分岐を追加する privateメソッドで分割すると良さげ
    # ここ予約 or 投稿済 の振り分けロジックを書くとPostControllerと重複が発生するので, Post.createを呼び出す形でも良さそう
    # if @draft.post_at
      # @draft.status = :reserved

    # 投稿済へ移動する
    self.to_published
  end

  private

    def draft_params
      params.require(:post).permit(:content)
    end

    # 投稿済に変更する
    def to_published
      @draft.to_published
      if @draft.save
        respond_to do |format|
          format.html { redirect_to root_url, notice: '投稿に成功しました' }
          format.js do
            @error_messages = []
            @action = 'published'
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to root_url, alert: '投稿に失敗しました' }
          format.js do
            @error_messages = error_messages_with_prefix(@draft, '投稿に失敗しました。')
            @action = 'published'
          end
        end
      end
    end
end
