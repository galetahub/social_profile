require 'spec_helper'

describe SocialProfile::People::Twitch do
  let(:uid) { '91708654' }
  let(:profile) { SocialProfile::Person.get(:twitch, uid, 'token') }
  let(:user) { JSON.parse fixture('twitch/user.json') }

  before do
    allow(profile).to receive(:user).and_return(user)
    stub_request(:get, 'https://api.twitch.tv/helix/users/follows').
      with(query: { to_id: uid, first: 100, after: nil }).
      to_return(status: 200, body: fixture('twitch/followers.json'))
    stub_request(:get, 'https://api.twitch.tv/helix/users/follows').
      with(query: { from_id: uid, first: 100, after: nil }).
      to_return(status: 200, body: fixture('twitch/followings.json'))
  end

  it 'fetches username' do
    expect(profile.username).to eq 'marvellous_li'
  end

  it 'fetches view count' do
    expect(profile.view_count).to eq 1191298
  end

  it 'fetches followers count' do
    expect(profile.followers_count).to eq 15438
  end

  it 'fetches followings count' do
    expect(profile.followings_count).to eq 37
  end

  it 'fetches followers' do
    expect(profile.followers.count).to be >= 100
    expect(profile.followers).to all(be_a(described_class))
  end

  it 'fetches followings' do
    expect(profile.followings.count).to be >= 37
    expect(profile.followings).to all(be_a(described_class))
  end
end
