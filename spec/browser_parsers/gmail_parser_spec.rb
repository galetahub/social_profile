require 'spec_helper'

describe SocialProfile::BrowserParsers::GmailParser do
  let(:parser) { described_class.new('https://accounts.google.com/signin') }

  describe '#login' do
    it { expect { parser.login }.not_to raise_error }

    context 'when user already logged in' do
      before { allow(parser).to receive(:logged_in?).and_return(true) }

      it 'skips login process' do
        expect(parser).not_to receive(:click_link)
        expect { parser.login }.not_to raise_error
      end
    end

    context 'when alert is not present on the page' do
      before do
        allow(parser).to receive(:visit)
        allow(parser).to receive(:logged_in?).and_return(true)
        allow(parser).to receive(:accept_alert).and_raise Capybara::ModalNotFound
      end

      it 'skips alert accepting' do
        expect { parser.login }.not_to raise_error
      end
    end
  end

  describe '#verification_code' do
    it { expect(parser.verification_code).to be_a String }

    context 'when Selenium::WebDriver::Error::StaleElementReferenceError occurs during parsing the code' do
      before do
        allow(parser).to receive(:login)
        allow(parser).to receive(:assert_selector)
        allow(parser).to receive(:first).and_return(double(click: nil))
        allow(parser).to receive(:all).with('font', wait: 10, minimum: 1).
          and_raise Selenium::WebDriver::Error::StaleElementReferenceError
      end

      it 'returns the empty string after 4 attempts to retry' do
        expect(parser).to receive(:with_error_handling).exactly(4).times.and_call_original
        expect(parser.verification_code).to eq ''
      end
    end
  end
end
