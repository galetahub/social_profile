require 'spec_helper'

describe SocialProfile::People::Facebook do
  it 'should be a Module' do
    expect(SocialProfile::People).to be_a Module
  end

  context 'facebook' do
    let(:user) { SocialProfile::Person.get(:facebook, '100000730417342', 'abc') }

    before :all do
      # FbGraph.debug!
    end

    it 'should be a facebook profile' do
      expect(user).to be_a described_class
    end

    it 'should response to friends_count' do
      stub_request(:get, 'https://graph.facebook.com/v2.8/me/friends?limit=1').
        to_return(status: 200, body: fixture('facebook/friends_count.json'))

      expect(user.friends_count).to eq 328
    end

    it 'should response to followers_count' do
      expect(user.followers).to be_empty
    end

    it 'should response to followers without limits (without fetch_all)' do
      expect(user.followers).to be_empty
    end

    it 'should response to followers without limits (with fetch_all)' do
      expect(user.followers(fetch_all: true)).to be_empty
    end

    it 'should response to followers list with limits' do
      expect(user.followers(limit: 5, fetch_all: true)).to be_empty
    end

    it 'should response to first_post_exists?' do
      expect(user.first_post_exists?(2011)).to be_nil
    end

    context 'last_posts' do
      let(:fields) { SocialProfile::People::Facebook::LAST_POSTS_FIELDS.join(',') }
      let(:posts) { user.last_posts(600) }

      before do
        stub_request(:get, "https://graph.facebook.com/v2.8/me/feed?fields=#{fields}&limit=600").
          to_return(status: 200, body: fixture('facebook/last_posts.json'))
      end

      it 'should response to last_posts' do
        expect(posts).to be_a Array
        expect(posts.size).to eq 239
      end
    end

    context 'with 3 request to facebook api' do
      let(:fields) { SocialProfile::People::Facebook::LAST_POSTS_FIELDS.join(',') }
      let(:fields2) { fields.gsub('.fields(created_time)', '') }
      let(:posts) { user.last_post_by_days(10, limit: 5, date_end: DateTime.new(2014, 3, 15)) }

      before do
        stub_request(:get, "https://graph.facebook.com/v2.8/me/feed?fields=#{fields}&limit=5").
          to_return(status: 200, body: fixture('facebook/last_5_posts.json'))
        stub_request(:get, "https://graph.facebook.com/v2.8/me/feed?fields=#{fields2}&limit=5&until=1394475325").
          to_return(status: 200, body: fixture('facebook/last_5_posts_page_2.json'))
        stub_request(:get, "https://graph.facebook.com/v2.8/me/feed?fields=#{fields2}&limit=5&until=1394439420").
          to_return(status: 200, body: fixture('facebook/last_5_posts_page_3.json'))
      end

      it 'should response to last_posts by days' do
        expect(posts).to be_a Array
        expect(posts.size).to eq 13
      end
    end

    context 'with big data' do
      let(:fields) do
        ['comments.limit(1000).fields(created_time,from).summary(true)',
         'likes.limit(1000).fields(id).summary(true)', 'shares', 'status_type']
      end
      let(:posts) do
        user.last_post_by_days(30, limit: 1000, date_end: DateTime.new(2014, 4, 6), fields: fields)
      end
      let(:shared_posts) { posts.select { |p| p.raw_attributes['status_type'] == 'shared_story' } }

      before do
        stub_request(:get, "https://graph.facebook.com/v2.8/me/feed?fields=#{fields.join(',')}&limit=1000").
          to_return(status: 200, body: fixture('facebook/last_posts_big.json'))
        stub_request(:get, "https://graph.facebook.com/v2.8/me/feed?fields=#{fields.join(',')}&limit=1000&until=1394789304").
          to_return(status: 200, body: fixture('facebook/last_posts_big2.json'))
      end

      it 'should get big data from last_posts' do
        expect(posts).to be_a Array
        expect(posts.size).to eq 56
        expect(shared_posts.size).to eq 13
      end
    end

    context 'friends list' do
      let(:friends) { user.friends(limit: 100000) }

      before do
        stub_request(:get, 'https://graph.facebook.com/v2.8/me/friends?limit=100000').
          to_return(status: 200, body: fixture('facebook/friends.json'))
      end

      it 'should get friends list' do
        expect(friends).to be_a Array
        expect(friends.size).to eq 4343
      end
    end

    context 'mutual friends' do
      let(:mutual_friends) { user.mutual_friends }

      it 'should get mutual friends' do
        expect(mutual_friends).to be_a Hash
        expect(mutual_friends).to be_empty
      end
    end
  end
end
