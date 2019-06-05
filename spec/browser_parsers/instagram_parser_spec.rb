require 'spec_helper'

describe SocialProfile::BrowserParsers::InstagramParser do
  let(:parser) { described_class.new('https://www.instagram.com') }

  describe '#login' do
    it { expect { parser.login }.not_to raise_error }

    context 'when user already logged in' do
      before { allow(parser).to receive(:logged_in?).and_return(true) }

      it 'skips login process' do
        expect(parser).not_to receive(:click_link)
        expect { parser.login }.not_to raise_error
      end
    end

    context 'when user need verification' do
      before do
        allow(parser).to receive(:need_verification?).and_return(true)
        allow(parser).to receive(:logged_in?)
        allow(parser).to receive(:visit)
        allow(parser).to receive(:accept_alert_if_present)
        allow(parser).to receive(:click_link)
        allow(parser).to receive(:click_button)
        allow(parser).to receive(:assert_no_selector)
        allow(parser).to receive(:fill_in)
      end

      it 'verifies user' do
        expect(parser).to receive(:verification_process)
        expect { parser.login }.not_to raise_error
      end
    end
  end

  describe '#followers_usernames' do
    it 'parses followers usernames' do
      expect(parser.followers_usernames('pavel_galeta', fetch_count: 10, followers_count: 20).size).to be >= 10
    end

    context 'when Selenium::WebDriver::Error::StaleElementReferenceError occurs during parsing the followers' do
      before do
        allow(parser).to receive(:login).and_return(true)
        allow(parser).to receive(:visit)
        allow(parser).to receive(:private_account?)
        allow(parser).to receive(:click_link)
        allow(parser).to receive(:load_followers)
        allow(parser).to receive(:all).and_raise Selenium::WebDriver::Error::StaleElementReferenceError
      end

      it 'returns the empty array after 4 attempts to retry' do
        expect(parser).to receive(:with_error_handling).exactly(4).times.and_call_original
        expect(parser.followers_usernames('test', fetch_count: 1, followers_count: 1)).to be_empty
      end
    end

    context 'when account is private' do
      before do
        allow(parser).to receive(:login).and_return(true)
        allow(parser).to receive(:visit)
        allow(parser).to receive(:private_account?).and_return(true)
      end

      it 'returns the empty array' do
        expect(parser.followers_usernames('test', followers_count: 1)).to be_empty
      end
    end

    context 'when site not loading' do
      before { allow(parser).to receive(:visit).and_raise Net::ReadTimeout }

      it 'returns the empty array after 4 attempts to relogin' do
        expect(parser).to receive(:login).exactly(4).times.and_call_original
        expect(parser.followers_usernames('test', followers_count: 10)).to be_empty
      end
    end
  end
end
