class Posts::DraftsController < ApplicationController
  before_action :redirect_to_root_if_not_logged_in

  def index
    # indexの場合はdraftsを更新日時の降順で取得する
    @drafts = current_user.drafts_by_recently_updated.
      page(params[:page]).per(10)
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

    # params[:to]に渡した値で分岐する
    if params[:to] == 'published'
      self.to_published!
    elsif params[:to] == 'scheduled'
      self.to_scheduled!
    else
      # TODO エラー投げる
    end
  end

  private

    def draft_params
      params.require(:post).permit(:content, :post_at)
    end

    # TODO sendメソッドでDRYにできそう
    # 下書きを投稿する(インスタンス変数を直接操作する)
    def to_published!
      @draft.to_published

      if @draft.save
        respond_to do |format|
          format.html { redirect_to root_url, notice: '投稿に成功しました' }
          format.js do
            @error_messages = []
            @to = 'published'
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to root_url, alert: '投稿に失敗しました' }
          format.js do
            @error_messages = error_messages_with_prefix(@draft, '投稿に失敗しました。')
            @to = 'published'
          end
        end
      end
    end

    # 下書きを予約投稿へ(インスタンス変数を直接操作する)
    def to_scheduled!
      # NOTE: post_atが登録されていなければeditに飛ばす
      unless @draft.post_at
        @error_messages = ['予約投稿に失敗しました。', '予約投稿するには投稿日時を設定してください。']
        render :edit, content_type: 'text/javascript' and return
      end

      @draft.to_scheduled

      if @draft.save
        respond_to do |format|
          format.html { redirect_to drafts_url, notice: '予約投稿に成功しました' }
          format.js do
            @error_messages = []
            @to = 'scheduled'
          end
        end
      else
        respond_to do |format|
          format.html { redirect_to drafts_url, alert: '予約投稿に失敗しました' }
          format.js do
            @error_messages = error_messages_with_prefix(@draft, '予約投稿に失敗しました。')
            @to = 'scheduled'
          end
        end
      end
    end
end
