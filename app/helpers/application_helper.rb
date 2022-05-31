module ApplicationHelper
  # 完全なタイトルを返す
  def full_title(page_title='')
    base_title = 'Twitter Outputter'
    if page_title.empty?
      return base_title
    else
      return "#{page_title} - #{base_title}"
    end
  end
end
