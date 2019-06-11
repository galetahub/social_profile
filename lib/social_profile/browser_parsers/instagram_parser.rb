module SocialProfile
  module BrowserParsers
    class InstagramParser < BrowserParser
      FOLLOWER_XPATH = "//div[contains(., 'Followers')]/following-sibling::div/ul//li//div/a[not(img)]".freeze

      def login(attempts = 3)
        visit @url

        click_button 'This Was Me' if person_confirmation?
        with_error_handling(return_on_fail: false) do
          accept_alert_if_present
          return true if logged_in?

          click_link 'Log in'
          assert_no_selector(:xpath, "//button[contains(., 'Sign up')]", wait: 5)
          fill_in 'username', with: @username
          fill_in 'password', with: @password
          click_button 'Log In'
          verification_process if need_verification? || code_sent?

          true
        end
      rescue Capybara::ElementNotFound, Net::ReadTimeout
        return false if attempts.zero?

        login(attempts - 1)
      end

      def followers_usernames(username, fetch_count: 200, followers_count:)
        # To avoid exceptions we return the empty array in case with failed login
        return [] unless login

        visit "#{@url}/#{username}"
        # When account is private we just return the empty array
        return [] if private_account?

        count = fetch_count > followers_count ? followers_count : fetch_count
        click_link 'followers'
        load_followers count

        with_error_handling(return_on_fail: []) { followers.map(&:text) }
      end

      private

      def logged_in?
        has_xpath? "//span[contains(@aria-label, 'Profile')]", wait: 5
      end

      def need_verification?
        has_text? 'Suspicious Login Attempt'
      end

      def code_sent?
        has_text? 'Enter Your Security Code'
      end

      def private_account?
        has_text? 'This Account is Private'
      end

      def person_confirmation?
        has_text? 'We Detected An Unusual Login Attempt'
      end

      def verification_process
        # We are requesting a new code, because the old one may be invalid already
        action_title = code_sent? ? 'Get a new one' : 'Send Security Code'
        click_on action_title

        code = nil
        within_new_window do
          gmail_parser = GmailParser.new('https://accounts.google.com/signin')
          code = gmail_parser.verification_code
        end

        find(:xpath, "//input[contains(@aria-label, 'Security code')]").set(code)
        submit_title = 'Submit'
        click_on submit_title
        assert_no_selector(:xpath, "//*[contains(text(), '#{submit_title}')]", wait: 10)
      end

      def followers
        all(:xpath, FOLLOWER_XPATH, wait: 10)
      end

      def load_followers(count)
        scrolls_count = count
        assert_selector(:xpath, FOLLOWER_XPATH, wait: 15)
        loop do
          with_error_handling do
            first(:xpath, FOLLOWER_XPATH).send_keys(:down)
          end
          # We use count here to avoid parsing followers after each scroll
          # (one scroll scrolls about one user down),
          # and only when count will equal to zero we will check count of loaded followers.
          scrolls_count -= 1 if scrolls_count > 0

          break if scrolls_count.zero? && followers.count >= count
        end
      end
    end
  end
end
