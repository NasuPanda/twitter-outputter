class Posts::EditingsController < ApplicationController
  def update
    @tag_name = params[:tag_name]
  end
end
