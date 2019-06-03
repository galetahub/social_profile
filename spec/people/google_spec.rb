require 'spec_helper'

describe SocialProfile::People::Google do
  it 'should be a Module' do
    expect(described_class).to be_a Module
  end

  context 'google' do
    let(:user) { SocialProfile::Person.get(:google, '123456', 'abc') }

    before do
      stub_request(:get, 'https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics').
        to_return(status: 200, body: fixture('google/channels.json'))
    end

    it 'should be a google profile' do
      expect(user).to be_a described_class
    end

    it 'should response to friends_count' do
      expect(user.friends_count).to eq 2
    end
  end
end
