require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'full_title' do
    let(:base_title) { 'Twitter Outputter' }

    context '引数を渡さなかったとき' do
      it 'base_titleを返すこと' do
        expect(helper.full_title).to eq(base_title)
      end
    end

    context '引数に文字列を渡したとき' do
      it '文字列 - base_titleを返すこと' do
        expect(helper.full_title('設定')).to eq("設定 - #{base_title}")
        expect(helper.full_title('下書き')).to eq("下書き - #{base_title}")
      end
    end
  end

  describe 'within_a_day_from_now?' do
    before { travel_to(Time.zone.local(2022, 4, 1, 0, 0, 0)) }

    context '引数に現在日時を渡したとき' do
      it 'trueを返すこと' do
        expect(helper.within_a_day_from_now?(Time.current)).to eq(true)
      end
    end

    context '引数に数時間前を渡したとき' do
      it 'trueを返すこと' do
        expect(helper.within_a_day_from_now?(rand(1..10).hours.ago)).to eq(true)
      end
    end

    context '引数に23時間59分前を渡したとき' do
      it 'trueを返すこと' do
        current = Time.zone.local(2022, 3, 31, 0, 1, 0)
        expect(helper.within_a_day_from_now?(current)).to eq(true)
      end
    end

    context '翌日の現在時刻を渡したとき' do
      it 'falseを返すこと' do
        current = Time.zone.local(2022, 4, 2, 0, 0, 0)
        expect(helper.within_a_day_from_now?(current)).to eq(true)
      end
    end
  end

  describe 'join_words_with_newline' do
    context '引数に要素が1つのリストを渡したとき' do
      it '要素をそのまま返すこと' do
        expect(helper.join_words_with_newline(['test'])).to eq('test')
      end
    end

    context '引数に要素を2つ以上含むリストを渡したとき' do
      it '改行で結合して返すこと' do
        # JavaScriptで使う都合上エスケープが必要
        expect(
          helper.join_words_with_newline(['test1', 'test2'])
        ).to eq('test1\\ntest2')
        expect(
          helper.join_words_with_newline(['test1', 'test2', 'test3'])
        ).to eq('test1\\ntest2\\ntest3')
      end
    end
  end
end