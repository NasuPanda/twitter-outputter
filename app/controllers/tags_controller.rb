class TagsController < ApplicationController
  def new
    @tag = current_user.tags.build
  end

  def create
    @tag = current_user.tags.build(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to root_path, notice: "タグを作成しました" }
        format.json { render json: @tag }
        format.js { @status = "success" }
      else
        format.html { redirect_to root_path, notice: "タグの作成に失敗しました" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
        format.js { @status = "failure" }
      end
    end
  end

  def edit
    @tag = current_user.tags.find(params[:id])
  end

  def update
    # TODO Ajaxに対応する
    @tag = current_user.tags.find(params[:id])
    if @tag.update(tag_params)
      redirect_to root_path, notice: "タグを更新しました"
    end
  end

  def destroy
    # TODO Ajaxに対応する
    @tag = current_user.tags.find(params[:id])
    @tag.destroy!
    redirect_to root_path, notice: "タグを削除しました"
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
