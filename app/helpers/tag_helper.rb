module TagHelper
  def tag_id(tag)
    return "tag-#{tag.id}"
  end

  def added_tag_id(tag)
    return "added-tag-#{tag.id}"
  end
end
