module AlertSupport
  def find_alert(page)
    retry_on_error { page.driver.browser.switch_to.alert }
  end

  def alert_text(page)
    find_alert(page).text
  end

  def accept_alert(page)
    find_alert(page).accept
  end

  private

    def retry_on_error(times: 5)
      try = 0
      begin
        try += 1
        yield
      rescue
        retry if try < times
        raise
      end
    end
end

RSpec.configure do |config|
  config.include AlertSupport, type: :system
end