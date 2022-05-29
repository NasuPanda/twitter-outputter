class TagsController < ApplicationController
  def new
    @tag = current_user.tags.build
  end

  def create
    @tag = current_user.tags.build(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to root_path, notice: 'タグを作成しました' }
        format.js { @status = 'success' }
      else
        format.html { redirect_to root_path, notice: 'タグの作成に失敗しました' }
        format.js { @status = 'failure' }
      end
    end
  end

  def edit
    @tag = current_user.tags.find(params[:id])
  end

  def update
    @tag = current_user.tags.find(params[:id])

    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to root_path, notice: 'タグを更新しました' }
        format.js { @status = 'success' }
      else
        format.html { redirect_to edit_tag_path(tag), notice: 'タグの更新に失敗しました' }
        format.js { @status = 'failure' }
      end
    end
  end

  def destroy
    @tag = current_user.tags.find(params[:id])

    respond_to do |format|
      if @tag.destroy!
        format.html { redirect_to root_path, notice: 'タグを削除しました' }
        format.js { @status = 'success' }
      else
        format.html { redirect_to edit_tag_path(tag), notice: 'タグの削除に失敗しました' }
        format.js { @status = 'failure' }
      end
    end
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
