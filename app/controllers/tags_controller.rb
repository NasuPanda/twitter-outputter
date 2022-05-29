class TagsController < ApplicationController
  before_action :redirect_to_root_if_not_logged_in
  before_action :redirect_to_root_if_incorrect_user, only: %i[edit update destroy]

  def new
    @tag = current_user.tags.build
  end

  def create
    @tag = current_user.tags.build(tag_params)
    @status = @tag.save ? 'success' : 'failure'
  end

  def edit
    @tag = current_user.tags.find(params[:id])
  end

  def update
    @tag = current_user.tags.find(params[:id])
    @status =  @tag.update(tag_params) ? 'success' : 'failure'
  end

  def destroy
    @tag = current_user.tags.find(params[:id])
    @status = @tag.destroy ? 'success' : 'failure'
  end

  private

    def tag_params
      params.require(:tag).permit(:name)
    end

    def redirect_to_root_if_incorrect_user
      tag = current_user.tags.find_by(id: params[:id])
      redirect_to root_url if tag.nil?
    end
end
