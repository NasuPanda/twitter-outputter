module Posts::DraftsHelper
  def draft_id(draft)
    return "draft-#{draft.id}"
  end
end
