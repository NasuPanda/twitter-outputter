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

  describe 'error_messages_with_prefix' do
    let(:post) { FactoryBot.create(:post) }

    context 'モデルがエラーメッセージを1つ持つとき' do
      before { post.errors[:content] << 'が無効です' }

      it '長さ2の配列を返すこと' do
        error_messages = helper.error_messages_with_prefix(post, '投稿に失敗しました')
        expect(error_messages.size).to eq(2)
      end

      it '配列の最初の要素がprefixとして渡したメッセージであること' do
        prefix = '投稿に失敗しました'
        error_messages = helper.error_messages_with_prefix(post, prefix)
        expect(error_messages.first).to eq(prefix)
      end

      it 'model.errors.full_messagesの要素を含むこと' do
        error_messages = helper.error_messages_with_prefix(post, '投稿に失敗しました')
        post.errors.full_messages.each do |message|
          expect(error_messages).to be_include(message)
        end
      end
    end

    context 'モデルがエラーメッセージを2つ持つとき' do
      before do
        post.errors[:content] << 'が無効です'
        post.errors[:post_at] << 'が無効です'
      end

      it '長さ3の配列を返すこと' do
        error_messages = helper.error_messages_with_prefix(post, '投稿に失敗しました')
        expect(error_messages.size).to eq(3)
      end

      it '配列の最初の要素がprefixとして渡したメッセージであること' do
        prefix = '投稿に失敗しました'
        error_messages = helper.error_messages_with_prefix(post, prefix)
        expect(error_messages.first).to eq(prefix)
      end

      it 'model.errors.full_messagesの要素を含むこと' do
        error_messages = helper.error_messages_with_prefix(post, '投稿に失敗しました')
        post.errors.full_messages.each do |message|
          expect(error_messages).to be_include(message)
        end
      end
    end

    context 'モデルがエラーメッセージを持たないとき' do
      it '長さ1の配列を返すこと' do
        error_messages = helper.error_messages_with_prefix(post, '投稿に失敗しました')
        expect(error_messages.size).to eq(1)
      end

      it '配列の要素がprefixとして渡したメッセージであること' do
        prefix = '投稿に失敗しました'
        error_messages = helper.error_messages_with_prefix(post, prefix)
        expect(error_messages.first).to eq(prefix)
      end
    end

    context 'Post以外のモデルのとき' do
      let(:tag) { FactoryBot.create(:tag) }

      context 'モデルがエラーメッセージを1つ持つとき' do
        before { tag.errors[:name] << 'が無効です' }

        it '長さ2の配列を返すこと' do
          error_messages = helper.error_messages_with_prefix(tag, '投稿に失敗しました')
          expect(error_messages.size).to eq(2)
        end

        it '配列の最初の要素がprefixとして渡したメッセージであること' do
          prefix = '投稿に失敗しました'
          error_messages = helper.error_messages_with_prefix(tag, prefix)
          expect(error_messages.first).to eq(prefix)
        end

        it 'model.errors.full_messagesの要素を含むこと' do
          error_messages = helper.error_messages_with_prefix(tag, '投稿に失敗しました')
          tag.errors.full_messages.each do |message|
            expect(error_messages).to be_include(message)
          end
        end
      end
    end
  end
end