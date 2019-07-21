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

    context 'when page does not contain js file with query hash' do
      before do
        allow(parser).to receive(:query_hash).and_raise SocialProfile::ProfileInternalError
        allow(parser).to receive(:logged_in?).and_return(true)
        allow(parser).to receive(:client).and_return(double(get: double(body: '')))
        allow(parser).to receive(:user_id)
      end

      it 'returns the empty array after 3 attempts to retry' do
        expect(parser).to receive(:followers_usernames).at_least(3).times.and_call_original
        expect(parser.followers_usernames('pavel_galeta', fetch_count: 100, followers_count: 100)).to be_empty
      end
    end
  end
end
