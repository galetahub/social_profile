require 'spec_helper'

describe SocialProfile::People::Twitter do
  it 'should be a Module' do
    expect(SocialProfile::People).to be_a Module
  end

  context 'twitter' do
    let(:user) do
      SocialProfile::Person.get(:twitter, '123456', 'abc', api_key: '111', api_secret: '222', token_secret: '333')
    end

    before do
      stub_request(:post, 'https://api.twitter.com/oauth2/token').with(body: { 'grant_type' => 'client_credentials' }).
        to_return(body: fixture('twitter/token.json'), headers: { content_type: 'application/json; charset=utf-8' })
      stub_request(:get, 'https://api.twitter.com/1.1/account/verify_credentials.json').
        to_return(body: fixture('twitter/auth.json'), headers: { content_type: 'application/json; charset=utf-8' })
      stub_request(:get, 'https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=false&screen_name=150587663&trim_user=true').
        to_return(status: 200, body: fixture('twitter/last_posts.json'))
    end

    it 'should be a twitter profile' do
      expect(user).to be_a described_class
    end

    it 'should response to friends_count' do
      expect(user.friends_count).to eq 69
    end

    context 'last_posts' do
      let(:posts) { user.last_posts('150587663') }
      let(:retweets_count) { posts.sum(&:retweet_count) }

      it 'should response to last_posts' do
        expect(retweets_count).to eq 9
        expect(posts.size).to eq 107
        # average user reach
        expect((user.friends_count + (retweets_count * 100) / posts.size)).to eq 77
      end
    end

    context 'get_all_tweets' do
      let(:posts) { user.last_posts('150587663') }

      it 'should response to get_all_tweets' do
        expect(posts.sum(&:retweet_count)).to eq 9
        expect(posts.size).to eq 107
      end
    end
  end
end
