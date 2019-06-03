# encoding: utf-8

require 'spec_helper'

describe SocialProfile::People::Vkontakte do
  it 'should be a Module' do
    expect(SocialProfile::People).to be_a Module
  end

  context 'vkontakte' do
    let(:user) { SocialProfile::Person.get(:vkontakte, '2592709', 'abc') }

    before do
      stub_request(:get, 'https://api.vk.com/method/users.get?access_token=abc&fields=counters&user_ids=2592709&v=5.24').
        to_return(status: 200, body: fixture('vkontakte/friends_count.json'))
      stub_request(:get, 'https://api.vk.com/method/wall.get?access_token=abc&count=100&filter=owner&offset=0&owner_id=2592709&v=5.24').
        to_return(status: 200, body: fixture('vkontakte/last_posts.json'))
      stub_request(:get, 'https://api.vk.com/method/likes.getList?access_token=abc&count=1000&item_id=655&offset=0&owner_id=2592709&type=post&v=5.24').
        to_return(status: 200, body: fixture('vkontakte/likes_post_655.json'))
      stub_request(:get, 'https://api.vk.com/method/likes.getList?access_token=abc&count=1000&item_id=290498375&offset=0&owner_id=2592709&type=photo&v=5.24').
        to_return(status: 200, body: fixture('vkontakte/likes_photo_290498375.json'))
      stub_request(:get, 'https://api.vk.com/method/wall.getComments?access_token=abc&count=100&need_likes=1&offset=0&owner_id=2592709&post_id=655&preview_length=0&v=5.24').
        to_return(status: 200, body: fixture('vkontakte/comments_post_655.json'))
      stub_request(:get, 'https://api.vk.com/method/photos.getAllComments?access_token=abc&count=100&need_likes=1&offset=0&owner_id=2592709&uid=2592709').
        to_return(status: 200, body: fixture('vkontakte/comments_photos.json'))
      stub_request(:get, 'https://api.vk.com/method/friends.get?access_token=abc&count=5000&fields=domain&offset=0&user_id=2592709&v=5.24').
        to_return(status: 200, body: fixture('vkontakte/friends.json'))
      stub_request(:get, 'https://api.vk.com/method/users.getFollowers?access_token=abc&count=1000&fields=screen_name&offset=0&user_id=2592709&v=5.24').
        to_return(status: 200, body: fixture('vkontakte/followers.json'))
      stub_request(:get, 'https://api.vk.com/method/wall.getReposts?access_token=abc&count=1000&offset=0&owner_id=2592709&post_id=3675&v=5.24').
        to_return(status: 200, body: fixture('vkontakte/shares_post_3675.json'))
      stub_request(:get, 'https://api.vk.com/method/wall.getById?access_token=abc&extended=1&posts=2592709_655&v=5.24').
        to_return(status: 200, body: fixture('vkontakte/post.json'))
    end

    it 'should be a vkontakte profile' do
      expect(user).to be_a described_class
    end

    it 'should response to friends_count' do
      expect(user.friends_count).to be > 0
    end

    it 'should response to last_posts' do
      expect(user.last_posts.size).to eq 100
    end

    it 'should response to last_post_by_days by 30 days' do
      expect(user.last_post_by_days(30)).to be_empty
    end

    it 'should response to last_post_by_days by 30 days with date_end options' do
      expect(user.last_post_by_days(30, date_end: DateTime.new(2014, 5, 17))).to be_one
    end

    context 'for 2119 days' do
      let(:posts) { user.last_post_by_days(2119, date_end: DateTime.new(2014, 8, 19)) }
      let(:text) { 'хочеш узнать про меня побольше? введи в google ник super_p.' }

      before do
        stub_request(:get, 'https://api.vk.com/method/wall.get?access_token=abc&count=100&filter=owner&offset=100&owner_id=2592709&v=5.24').
          to_return(status: 200, body: fixture('vkontakte/last_posts_2.json'))
      end

      it 'should response to last_post_by_days' do
        expect(posts.size).to eq 175
        expect(posts.last['text']).to eq text
      end
    end

    it 'should response to object_likes' do
      expect(user.object_likes('655')['items'].size).to eq 7
      expect(user.object_likes('290498375', type: 'photo')['items'].size).to eq 17
    end

    it 'should response to object_likes with fetch_all' do
      expect(user.object_likes('655', fetch_all: true).size).to eq 7
      expect(user.object_likes('290498375', type: 'photo', fetch_all: true).size).to eq 17
    end

    it 'should response to post_comments' do
      expect(user.post_comments('655')['items'].size).to eq 3
    end

    it 'should response to post_comments with fetch_all' do
      expect(user.post_comments('655', fetch_all: true).size).to eq 3
    end

    it 'should response to post_shares' do
      expect(user.post_shares('3675')['items'].size).to eq 21
    end

    it 'should response to post_shares with fetch_all' do
      expect(user.post_shares('3675', fetch_all: true).size).to eq 21
    end

    it 'should response to photos_comments' do
      expect(user.photos_comments.size).to eq 100
    end

    it 'should response to photos_comments with days' do
      expect(user.photos_comments(days: 30)).to be_empty
    end

    it 'should fetch all friends' do
      expect(user.friends.size).to eq 208
    end

    it 'should fetch all followers' do
      expect(user.followers.size).to eq 30
    end

    context 'with iteration by 20 items in step' do
      before do
        stub_request(:get, 'https://api.vk.com/method/users.getFollowers?access_token=abc&count=20&fields=screen_name&offset=0&user_id=2592709&v=5.24').
          to_return(status: 200, body: fixture('vkontakte/followers_20.json'))
        stub_request(:get, 'https://api.vk.com/method/users.getFollowers?access_token=abc&count=20&fields=screen_name&offset=20&user_id=2592709&v=5.24').
          to_return(status: 200, body: fixture('vkontakte/followers_20_2.json'))
      end

      it 'should fetch all followers' do
        expect(user.followers(count: 20).size).to eq 30
      end
    end

    it 'should fetch post by id' do
      expect(user.get_post('2592709_655')['items'].first['comments']['count']).to eq 3
    end

    context 'mutual_friends' do
      before do
        stub_request(:get, /friends\.getMutual/).
          to_return(status: 200, body: fixture('vkontakte/mutual_friends.json'))
      end

      it 'should get mutual_friends' do
        expect(user.mutual_friends(target_uids: 'seperated_ids').size).to eq 206
      end
    end
  end
end
