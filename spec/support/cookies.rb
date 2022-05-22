class Rack::Test::CookieJar
  # cookies.signedが未定義になる現象への対処
  def encrypted; self; end
  def signed; self; end
  def permanent; self; end
end