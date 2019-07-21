require 'spec_helper'

describe SocialProfile::People::InstagramParser do
  let(:user) { SocialProfile::Person.get(:instagram_parser, 'pavel_galeta', nil) }
  let(:post_uid) { 'BgTecbzDo2UB3AvPHBV9GNKriGiUYFDow_RP-o0' }

  context 'instagram parser' do
    before do
      stub_request(:get, 'https://www.instagram.com/pavel_galeta/media/').
        to_return(status: 200, body: fixture('instagram_parser/media.json'))
      stub_request(:get, 'https://www.instagram.com/pavel_galeta/').
        to_return(status: 200, body: fixture('instagram_parser/user.html'))
      stub_request(:get, "https://www.instagram.com/p/#{post_uid}/?__a=1").
        to_return(status: 200, body: fixture('instagram_parser/post.json'))
    end

    it 'should be a instagram profile' do
      expect(user).to be_a described_class
    end

    it 'should response to username' do
      expect(user.username).to eq 'pavel_galeta'
    end

    it 'should response to last_posts' do
      expect(user.last_posts.size).to eq 12
    end

    it 'should response to user' do
      expect(user.user['username']).to eq 'pavel_galeta'
      expect(user.user['id']).to eq '31973911'
    end

    it 'should response to friends_count' do
      expect(user.friends_count).to eq 106
    end

    it 'should response to subscriptions_count' do
      expect(user.subscriptions_count).to eq 107
    end

    it 'should response to has_avatar?' do
      expect(user).to be_has_avatar
    end

    context 'get_post' do
      let(:post) { user.get_post(post_uid) }

      it 'should response to get_post' do
        expect(post['shortcode']).to eq(post_uid)
        expect(post['edge_media_to_comment']['count']).to eq(2)
        expect(post['edge_media_preview_like']['count']).to eq(7)
        expect(post['taken_at_timestamp']).to eq(1521031947)
      end
    end
  end

  describe '#friends' do
    let(:friends) { user.friends(count: 10) }
    let(:follower_friends) { friends.first.friends(count: 10) }

    it 'returns a list of friends' do
      expect(friends.size).to be >= 10
      expect(friends).to all(be_an(described_class))
    end

    it 'returns a list of follower friends' do
      expect(follower_friends.size).to be >= 10
      expect(follower_friends).to all(be_an(described_class))
    end
  end
end
