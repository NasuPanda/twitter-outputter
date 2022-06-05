class Tags::AddedController < ApplicationController
  def create
    # TODO sessionか何かでおぼえておくようにする
    @tag_name = params[:tag_name]
  end

  def destroy
  end
end
