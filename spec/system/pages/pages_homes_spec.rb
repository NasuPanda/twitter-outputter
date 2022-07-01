require 'rails_helper'

RSpec.describe "Pages::Homes", type: :system do
  # FIXME: js => true にするとsign_in_as(Omniauthのコールバックを呼び出す処理)が効かない
  # POST出来ないことが原因？
  describe 'タグ作成のテスト', js: true do
    let!(:user) { FactoryBot.create(:user, :with_authentication) }
    before do
      sign_in_as(user)
      visit root_path
    end

    scenario 'ユーザが有効な値を入力して新規タグ作成' do
      expect {
        click_link 'タグを追加'
        fill_in 'タグ名', with: '新しいタグ'
        click_button '登録'
        expect(page).to have_content('タグの作成に成功しました')
      }.to change{ Tag.count }.from(0).to(1)
    end

    scenario 'ユーザが無効な値を入力して新規タグ作成' do
      expect {
        click_link 'タグを追加'
        fill_in 'タグ名', with: '##無効なタグ'
        click_button '登録'
        expect(alert_text(page)).to include('タグの作成に失敗しました')
        accept_alert(page)
      }.to_not change{ Tag.count }
    end

    scenario 'ユーザが既存のタグと重複する値を入力して新規タグ作成' do
      # 現在のユーザが所有するタグを作成しておく
      tag = FactoryBot.create(:tag, user: user)

      expect {
        click_link 'タグを追加'
        fill_in 'タグ名', with: tag.name
        click_button '登録'
        sleep 1
        alert = find_alert(page)
        expect(alert_text(page)).to include('タグの作成に失敗しました')
        accept_alert(page)
      }.to_not change{ Tag.count }
    end
  end

  describe '投稿のテスト' do
    let(:user) { FactoryBot.create(:user, :with_authentication) }
    scenario 'ユーザが有効な値を入力して投稿' do
    end

    scenario 'ユーザが画像を添付して投稿' do
    end

    scenario 'ユーザが無効な値を入力して投稿' do
    end

    scenario 'ユーザが既存の投稿と重複する値を入力して投稿' do
    end
  end
end
