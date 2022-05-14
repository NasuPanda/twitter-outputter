require 'rails_helper'

RSpec.describe "Welcomes", type: :request do
  describe "root" do
    it "正常なレスポンスを返すこと" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end

end
