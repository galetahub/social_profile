require 'capybara/dsl'
require 'selenium/webdriver'

module SocialProfile
  # This class provide logic for parsing data using browser
  class BrowserParser
    include Capybara::DSL

    def initialize(url)
      register_driver
      Capybara.run_server = false
      Capybara.current_driver = :chrome

      @url = url
      @username = env_variable 'username'
      @password = env_variable 'password'
    end

    def login
      raise NotImplementedError, 'Subclasses should implement this!'
    end

    private

    def within_new_window
      open_new_window
      switch_to_window windows.last

      yield

      page.driver.browser.close
      switch_to_window windows.first
    end

    def with_error_handling(attempts = 3, return_on_fail: nil)
      yield
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      # To avoid exception when attempts are over, we just return some default value.
      # It should be the value with the same type as returns the block.
      return return_on_fail if attempts.zero?

      with_error_handling(attempts - 1, return_on_fail: return_on_fail) { yield }
    end

    def accept_alert_if_present
      accept_alert
    rescue Capybara::ModalNotFound
      # Exception means that alert not present on the page
    end

    def env_variable(name)
      ENV["#{service_name}_#{name}".upcase]
    end

    def service_name
      self.class.name[/::(\w+)Parser$/, 1].downcase
    end

    def register_driver
      Capybara.register_driver :chrome do |app|
        driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
        driver
      end
    end

    def chrome_options
      opts = Selenium::WebDriver::Chrome::Options.new
      opts.add_argument('--headless') unless ENV['UI']
      opts.add_argument('--no-sandbox')
      opts.add_argument('--disable-gpu')
      opts.add_argument('--disable-dev-shm-usage')
      opts.add_argument('--window-size=1400,1400')
      opts.add_argument("--user-data-dir=/tmp/social_profile/#{service_name}")
      opts.add_argument('--enable-features=NetworkService,NetworkServiceInProcess')
      opts.add_option('prefs', 'intl.accept_languages': 'en-US')

      opts
    end
  end
end
