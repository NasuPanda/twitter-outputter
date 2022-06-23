require 'rails_helper'

RSpec.describe TagHelper, type: :helper do

  describe 'tag_id' do
    it 'tag-#{tag.id}を返すこと' do
      tag = double('tag', id: 1)
      tag_2 = double('tag2', id: 2)
      tag_100 = double('tag100', id: 100)
      expect(helper.tag_id(tag)).to eq('tag-1')
      expect(helper.tag_id(tag_2)).to eq('tag-2')
      expect(helper.tag_id(tag_100)).to eq('tag-100')
    end
  end

  describe 'tagged_tag_id' do
    it 'tagged-tag-#{id}を返すこと' do
      tag = double('tag', id: 1)
      tag_2 = double('tag2', id: 2)
      tag_100 = double('tag100', id: 100)
      expect(helper.tagged_tag_id(tag)).to eq('tagged-tag-1')
      expect(helper.tagged_tag_id(tag_2)).to eq('tagged-tag-2')
      expect(helper.tagged_tag_id(tag_100)).to eq('tagged-tag-100')
    end
  end
end