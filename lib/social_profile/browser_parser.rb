require 'capybara/dsl'
require 'selenium/webdriver'
require 'yaml'
require 'fileutils'

module SocialProfile
  # This class provide logic for parsing data using browser
  class BrowserParser
    include Capybara::DSL

    def initialize(url, options = {})
      @current_driver = ENV['SOCIAL_PROFILE_BROWSER'].eql?('chrome') ? :chrome : :firefox
      register_driver
      Capybara.run_server = false
      Capybara.current_driver = @current_driver

      @cookies = options[:cookies] || get_cookies
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

    def add_cookies(cookies = [])
      cookies.each do |cookie|
        Capybara.current_session.driver.browser.manage.add_cookie(
          name: cookie[:name],
          value: cookie[:value],
          domain: cookie[:domain]
        )
      end
    end

    def save_cookies(cookies = [])
      return unless cookies.any?

      FileUtils.mkdir_p(tmp_path.join('cookies'))
      File.open(cookies_path, 'wb') { |f| f.write cookies.to_yaml }
    end

    def get_cookies
      return [] unless File.exists? cookies_path

      YAML.load_file(cookies_path)
    end

    def env_variable(name)
      ENV["#{service_name}_#{name}".upcase]
    end

    def service_name
      self.class.name[/::(\w+)Parser$/, 1].downcase
    end

    def register_driver
      Capybara.register_driver @current_driver do |app|
        Capybara::Selenium::Driver.new(app, browser: @current_driver, options: browser_options)
      end
    end

    def browser_options
      opts_class_str = "::Selenium::WebDriver::#{@current_driver.capitalize}::Options"
      opts = Object.const_get(opts_class_str).new
      opts.add_argument('--headless') unless ENV['UI']
      opts.add_argument('--no-sandbox')
      opts.add_argument('--disable-gpu')
      opts.add_argument('--disable-dev-shm-usage')
      opts.add_argument('--window-size=1400,1400')
      opts.add_argument("--user-data-dir=#{tmp_path.join(service_name)}")
      opts.add_argument('--enable-features=NetworkService,NetworkServiceInProcess')
      opts.add_option('prefs', 'intl.accept_languages': 'en-US')

      opts
    end

    def cookies_path
      tmp_path.join("cookies/#{service_name}.yml")
    end

    def tmp_path
      Pathname.new '/tmp/social_profile'
    end
  end
end
