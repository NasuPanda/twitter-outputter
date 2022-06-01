class Posts::DraftsController < ApplicationController
  def index
    @drafts = current_user.drafts
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
