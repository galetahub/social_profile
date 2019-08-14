require 'spec_helper'

describe SocialProfile::Providers::Twitch do
  let(:hash) { JSON.parse(fixture('twitch/auth.json')) }
  let(:profile) { SocialProfile.get(hash) }

  describe '#picture_url' do
    let(:picture_url) do
      'https://static-cdn.jtvnw.net/jtv_user_pictures/3a2d6045-67c3-4425-baec-279a98cfed5d-profile_image-300x300.png'
    end

    it { expect(profile.picture_url).to eq picture_url }
  end

  it '#profile_url' do
    expect(profile.profile_url).to eq 'http://www.twitch.tv/oleksiivykhor'
  end
end
