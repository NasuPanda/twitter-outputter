class OnlyAjaxConstraints
  # ルーティングをAjaxリクエストに限定する
  def matches?(request)
    request.xhr?
  end
end
