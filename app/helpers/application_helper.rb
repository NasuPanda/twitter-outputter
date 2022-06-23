module ApplicationHelper
  # 完全なタイトルを返す
  def full_title(page_title='')
    base_title = 'Twitter Outputter'
    page_title.empty? ? base_title : "#{page_title} - #{base_title}"
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

  # モデルの持つエラーメッセージにprefixを付けて返す(非破壊)
  # NOTE: ApplicationControllerから使えるようにしてある
  def error_messages_with_prefix(model, prefix)
    error_messages = model.errors.full_messages.dup
    error_messages.prepend(prefix)
  end
end
