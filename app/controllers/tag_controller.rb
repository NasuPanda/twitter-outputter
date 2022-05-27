class TagController < ApplicationController
  def new
    @tag = current_user.tags.build
  end

  def create
    @tag = current_user.tags.build(tag_params)

    if @tag.save
      redirect_to root_path, notice: "タグを作成しました"
    end
  end

  def edit
    @tag = current_user.tags.find(params[:id])
  end

  def update
    @tag = current_user.tags.find(params[:id])
    if @tag.update(tag_params)
      redirect_to root_path, notice: "タグを更新しました"
    end
  end

  def destroy
    @tag = current_user.tags.find(params[:id])
    @tag.destroy!
    redirect_to root_path, notice: "タグを削除しました"
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
