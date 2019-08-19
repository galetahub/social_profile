require 'spec_helper'

describe SocialProfile::Providers::Telegram do
  let(:hash) { JSON.parse(fixture('telegram/auth.json')) }
  let(:profile) { SocialProfile.get(hash) }

  describe '#picture_url' do
    let(:picture_url) do
      'https://t.me/i/userpic/320/BC1XKlEE1xMH0K-nju_XGd8AgMIHx9AzHgFiRszlJks.jpg'
    end

    it { expect(profile.picture_url).to eq picture_url }
  end
end
