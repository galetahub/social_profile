require 'spec_helper'

describe SocialProfile::People::Instagram do
  it 'should be a Module' do
    expect(SocialProfile::People).to be_a Module
  end

  context 'instagram' do
    let(:user) { SocialProfile::Person.get(:instagram, '123456', 'abc') }

    before do
      stub_request(:get, 'https://api.instagram.com/v1/users/self/media/recent.json?access_token=abc&count=100').
        to_return(status: 200, body: fixture('instagram/last_posts.json'))
    end

    it 'should be a instagram profile' do
      expect(user).to be_a described_class
    end

    it 'should response to last_posts' do
      expect(user.last_posts.size).to eq 4
      expect(user.last_posts.first.likes['count']).to eq 6
    end
  end
end
