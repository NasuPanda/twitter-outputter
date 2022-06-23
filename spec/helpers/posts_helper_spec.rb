require 'rails_helper'

RSpec.describe PostsHelper, type: :helper do
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