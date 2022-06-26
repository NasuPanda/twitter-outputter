require 'rails_helper'

RSpec.describe PostsHelper, type: :helper do
  describe 'post_card_texts' do
    let(:opening_tag) { helper.send(:card_text_p_tag)[0] }
    let(:closing_tag) { helper.send(:card_text_p_tag)[1] }

    context '改行を含まないとき' do
      let(:text) { '改行コードを含まないテキスト' }

      it '返り値の各要素が開始タグ, 閉じタグを含むこと' do
        post = double('Post', content: text)
        helper.post_card_texts(post).each do |card_text|
          expect(card_text).to be_include(opening_tag)
          expect(card_text).to be_include(closing_tag)
        end
      end

      it '長さ1の配列が返ること' do
        post = double('Post', content: text)
        expect(helper.post_card_texts(post).size).to eq(1)
      end
    end

    context '改行文字を3つ含むとき' do
      let(:text) { "改行コードを\n3つ\n含む\nテキスト" }

      it '返り値の各要素が開始タグ, 閉じタグを含むこと' do
        post = double('Post', content: text)
        helper.post_card_texts(post).each do |card_text|
          expect(card_text).to be_include(opening_tag)
          expect(card_text).to be_include(closing_tag)
        end
      end

      it '長さ4の配列が返ること' do
        post = double('Post', content: text)
        expect(helper.post_card_texts(post).size).to eq(4)
      end

      it '返り値の各要素が正しいテキストを持つこと' do
        post = double('Post', content: text)
        first, second, third, fourth = helper.post_card_texts(post)
        expect(first).to be_include('改行コードを')
        expect(second).to be_include('3つ')
        expect(third).to be_include('含む')
        expect(fourth).to be_include('テキスト')
      end
    end

    context '改行文字を5つ含むとき' do
      let(:text) { "改行\nコード\nを\n5つ\n含む\nテキスト" }

      it '返り値の各要素が開始タグ, 閉じタグを含むこと' do
        post = double('Post', content: text)
        helper.post_card_texts(post).each do |card_text|
          expect(card_text).to be_include(opening_tag)
          expect(card_text).to be_include(closing_tag)
        end
      end

      it '長さ6の配列が返ること' do
        post = double('Post', content: text)
        expect(helper.post_card_texts(post).size).to eq(6)
      end

      it '返り値の各要素が正しいテキストを持つこと' do
        post = double('Post', content: text)
        first, second, third, fourth, fifth, sixth = helper.post_card_texts(post)
        expect(first).to be_include('改行')
        expect(second).to be_include('コード')
        expect(third).to be_include('を')
        expect(fourth).to be_include('5つ')
        expect(fifth).to be_include('含む')
        expect(sixth).to be_include('テキスト')
      end
    end
  end

  describe 'post_id' do
    it 'post-#{post.id}を返すこと' do
      post = double('Post', id: 1)
      post_2 = double('Post2', id: 2)
      post_100 = double('Post100', id: 100)
      expect(helper.post_id(post)).to eq('post-1')
      expect(helper.post_id(post_2)).to eq('post-2')
      expect(helper.post_id(post_100)).to eq('post-100')
    end
  end

  describe 'count_down_twitter_text' do
    context '1バイト文字が200字のとき' do
      it '40を返すこと' do
        text = 'a' * 200
        expect(helper.count_down_twitter_text(text)).to eq(40)
      end
    end

    context '2バイト文字が100字のとき' do
      it '40を返すこと' do
        text = 'あ' * 100
        expect(helper.count_down_twitter_text(text)).to eq(40)
      end
    end

    context '1バイト文字が280字のとき' do
      it '0を返すこと' do
        text = 'a' * 280
        expect(helper.count_down_twitter_text(text)).to eq(0)
      end
    end

    context '2バイト文字が140字のとき' do
      it '0を返すこと' do
        text = 'あ' * 140
        expect(helper.count_down_twitter_text(text)).to eq(0)
      end
    end

    context '1バイト文字が281字のとき' do
      it '-0.5を返すこと' do
        text = 'a' * 281
        expect(helper.count_down_twitter_text(text)).to eq(-0.5)
      end
    end

    context '2バイト文字が141字のとき' do
      it '-1を返すこと' do
        text = 'あ' * 141
        expect(helper.count_down_twitter_text(text)).to eq(-1)
      end
    end
  end
end