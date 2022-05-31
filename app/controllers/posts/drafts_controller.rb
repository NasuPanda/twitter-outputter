class Posts::DraftsController < ApplicationController
  def index
    @drafts = current_user.drafts
  end

  def create
  end
end
