require "test_helper"
require "socket"

def prepare_options
  driver_options = {
    desired_capabilities: {
      chromeOptions: {
        # args: %w[headless disable-gpu disable-dev-shm-usage] # preserve memory & cpu consumption
      }
    }
  }

  driver_options[:url] = ENV["SELENIUM_URL"] if ENV["SELENIUM_URL"]

  driver_options
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400], options: prepare_options

  setup do
    if ENV["SELENIUM_URL"]
      net = Socket.ip_address_list.detect{|addr| addr.ipv4_private? }
      ip = net.nil? ? 'localhost' : net.ip_address
      Capybara.app_host = "http://#{ip}:8200"
    end

    WebMock.disable_net_connect!(allow_localhost: true, allow: ['hub:4444', '172.18.0.2:8200', 'chromedriver.storage.googleapis.com'])

    # Capybara::Webmock.start
  end

  teardown do
    # Capybara::Webmock.stop
  end

  def visit_admin(path)
    credentials = Rails.application.credentials.dig(:test)[:authentication][:admin]
    visit "http://#{credentials[:username]}:#{credentials[:password]}@#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}#{path}"
  end

  def click_text(text, base=page)
    assert_text text
    base.find_all(:xpath, "//*[normalize-space(text())='#{text}']").first.try(:click)
  end
end
