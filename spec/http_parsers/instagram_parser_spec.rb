require 'spec_helper'

describe SocialProfile::HTTPParsers::InstagramParser do
  let(:parser) { described_class.new('https://www.instagram.com', ENV['INSTAGRAM_COOKIES_PATH']) }

  describe '#followers_usernames' do
    it 'parses followers usernames' do
      expect(parser.followers_usernames('pavel_galeta', fetch_count: 100, followers_count: 100).count).to be >= 100
    end

    context 'when user is not authorized' do
      before { allow(parser).to receive(:cookies).and_return('') }

      it 'raises AuthorizationError' do
        expect { parser.followers_usernames('') }.
          to raise_error SocialProfile::AuthorizationError, "#{described_class} not authorized!"
      end
    end
  end
end
