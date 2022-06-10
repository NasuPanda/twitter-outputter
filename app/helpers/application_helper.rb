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

  # 1日以内か判定する
  def within_a_day_from_now?(datetime)
    datetime > 1.day.ago
  end

  # リストを改行で結合する
  def join_words_with_newline(words)
    # "\n"だとJS側で unexpected token と出るため注意
    words.join('\n')
  end
end
