module SocialProfile
  module BrowserParsers
    class GmailParser < BrowserParser
      def login
        visit @url
        accept_alert_if_present
        return if logged_in?

        send_form 'email', @username unless has_text? @username
        send_form 'password', @password
      ensure
        visit 'https://gmail.com'
      end

      def verification_code
        login

        # I'm not sure that this is the good way to looking for unreaded email by class like 'zA zE',
        # but I did not found better solution yet.
        email_path = "//tr[contains(@class, 'zA zE')]"\
          "//span[contains(@email, 'security@mail.instagram.com')]"
        assert_selector(:xpath, email_path, wait: 30)
        first(:xpath, email_path).click
        with_error_handling(return_on_fail: '') { first('font').text }
      end

      private

      def logged_in?
        has_xpath? "//a[contains(@href, 'Logout')]", visible: :all, wait: 5
      end

      def send_form(title, value)
        wait_if_loading
        find(:xpath, "//input[contains(@type, '#{title}')]", visible: true, wait: 5).set(value)
        find(:xpath, "//*[contains(@name, 'signIn') or contains(@id, 'Next')]").click
      end

      def wait_if_loading
        path = "//div[contains(@role, 'progressbar')]"
        assert_no_selector(:xpath, path, wait: 10) if has_xpath? path
      end
    end
  end
end
