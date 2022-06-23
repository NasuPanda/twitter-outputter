module TagHelper
  def tag_id(tag)
    return "tag-#{tag.id}"
  end

  def tagged_tag_id(tag)
    return "tagged-tag-#{tag.id}"
  end
end
