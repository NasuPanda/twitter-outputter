Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development? || Rails.env.test?
    provider :twitter, "jC64rUrfYQzCypKLDCxPCTc26", "EUmsEkHzm5tzl754lhKmAV3HUPn43EpNc72AQPnFQKaUEkLboQ"
  else
		# 本番環境の設定: 秘密の文字列はcredentials.ymlから持ってくる
    provider :twitter,
      # Rails.application.credentials.twitter[:client_id],
      # Rails.application.credentials.twitter[:client_secret]
      "jC64rUrfYQzCypKLDCxPCTc26",
      "EUmsEkHzm5tzl754lhKmAV3HUPn43EpNc72AQPnFQKaUEkLboQ"
  end
end
