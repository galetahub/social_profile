require 'spec_helper'

describe SocialProfile::People::Twitch do
  let(:uid) { '181077473' }
  let(:profile) { SocialProfile::Person.get(:twitch, uid, 'token', api_version: api_version) }

  before do
    stub_request(:get, 'https://api.twitch.tv/helix/users/follows').
      with(query: { to_id: uid, first: 100, after: nil }).
      to_return(status: 200, body: fixture('twitch/followers.json'))
    stub_request(:get, 'https://api.twitch.tv/helix/users/follows').
      with(query: { from_id: uid, first: 100, after: nil }).
      to_return(status: 200, body: fixture('twitch/followings.json'))
  end

  context 'helix' do
    let(:api_version) { :helix }

    before do
      stub_request(:get, 'https://api.twitch.tv/helix/users').
        with(query: { id: uid }).
        to_return(status: 200, body: fixture('twitch/user.json'))
    end

    it { expect(profile.status).to be_nil }
    it { expect(profile.game).to be_nil }
    it { expect(profile.video_count).to be_nil }

    it 'uses helix client' do
      expect(profile).not_to receive(:kraken_client)
      expect(profile).to receive(:helix_client).and_call_original
      expect(profile).to be_helix
      expect(profile.user).to be_a Hash
    end

    it 'receives username' do
      expect(profile.username).to eq 'marvellous_li'
    end

    it 'receives view count' do
      expect(profile.view_count).to eq 1213055
    end

    it 'receives description' do
      expect(profile.description).to eq 'Princess of cinder'
    end

    it 'receives followers count' do
      expect(profile.followers_count).to eq 15438
    end

    it 'receives followings count' do
      expect(profile.followings_count).to eq 37
    end

    it 'receives followers' do
      expect(profile.followers.count).to be >= 100
      expect(profile.followers).to all(be_a(described_class))
      expect(profile.followers).to all(be_helix)
    end

    it 'receives followings' do
      expect(profile.followings.count).to be >= 37
      expect(profile.followings).to all(be_a(described_class))
      expect(profile.followers).to all(be_helix)
    end
  end

  context 'kraken' do
    let(:api_version) { :kraken }

    before do
      stub_request(:get, "https://api.twitch.tv/kraken/channels/#{uid}").
        to_return(status: 200, body: fixture('twitch/kraken_user.json'))
      stub_request(:get, "https://api.twitch.tv/kraken/channels/#{uid}/videos").
        to_return(status: 200, body: fixture('twitch/kraken_videos.json'))
    end

    it 'uses kraken client' do
      expect(profile).not_to receive(:helix_client)
      expect(profile).to receive(:kraken_client).and_call_original
      expect(profile).to be_kraken
      expect(profile.user).to be_a Hash
    end

    it 'receives username' do
      expect(profile.username).to eq 'marvellous_li'
    end

    it 'receives status' do
      expect(profile.status).to eq 'Симулятор поиска игры En/Ru'
    end

    it 'receives game' do
      expect(profile.game).to eq 'Overwatch'
    end

    it 'receives description' do
      expect(profile.description).to eq 'Princess of cinder'
    end

    it 'receives video count' do
      expect(profile.video_count).to eq 88
    end

    it 'receives view count' do
      expect(profile.view_count).to eq 1213055
    end

    it 'receives followers count' do
      expect(profile.followers_count).to eq 15405
    end

    it 'receives followers' do
      expect(profile.followers.count).to be >= 100
      expect(profile.followers).to all(be_a(described_class))
      expect(profile.followers).to all(be_kraken)
    end

    it 'receives followings' do
      expect(profile.followings.count).to be >= 37
      expect(profile.followings).to all(be_a(described_class))
      expect(profile.followings).to all(be_kraken)
    end
  end
end
