class CreateNotification
  include HTTParty

  API_URI = 'https://onesignal.com/api/v1/notifications'.freeze

  # インスタンスを生成してcallする
  def self.call(...)
    new(...).call
  end

  def initialize(contents:, type:, external_user_id:)
    @contents = contents
    @type     = type
    @external_user_id = external_user_id
  end

  def call
    HTTParty.post(API_URI, headers: headers, body: body)
  end

  private

  attr_reader :contents, :type, :external_user_id

  def headers
    {
      'Authorization': "Basic #{Rails.application.credentials.one_signal[:rest_api_key]}",
      'Content-Type': 'application/json'
    }
  end

  def body
    {
      'app_id': '7f94c2e3-f773-44f0-b8ea-c8ee9adbcfed',
      'url': 'https://twitter-outputter.herokuapp.com/',
      'data': { 'type': type },
      "channel_for_external_user_ids": "push",
      'include_external_user_ids': [external_user_id],
      'contents': contents
    }.to_json
  end
end