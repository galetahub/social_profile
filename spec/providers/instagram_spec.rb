require 'spec_helper'

describe SocialProfile::Providers::Instagram do
  it 'should be a Module' do
    expect(SocialProfile::Providers).to be_a Module
  end

  context 'instagram' do
    let(:hash) do
      {
        'provider' => 'instagram',
        'uid' => '31973911',
        'info' => {
          'nickname' => 'pavel_galeta',
          'name' => 'pavel galeta',
          'location' => 'Anytown, USA',
          'image' => 'http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png',
          'description' => 'a very normal guy.',
          'urls' => { 'Website' => nil, 'Twitter' => 'https://twitter.com/johnqpublic' }
        },
        'credentials' => { 'token' => 'a1b2c3d4...', 'secret' => 'abcdef1234' },
        'extra' => {
          'access_token' => '',
          'raw_info' => {
            'username' => 'pavel_galeta',
            'bio' => '', 'website' => '',
            'profile_picture' => 'http://images.ak.instagram.com/profiles/anonymousUser.jpg',
            'full_name' => 'pavel galeta',
            'counts' =>  { 'media' => 62, 'followed_by' => 30, 'follows' => 34 },
            'id' => '31973911'
          }
        }
      }
    end
    let(:profile) { SocialProfile.get(hash) }

    it 'should be a instagram profile' do
      expect(profile).to be_a described_class
    end

    it 'should parse profile' do
      expect(profile.name).to eq 'pavel galeta'
      expect(profile.friends_count).to eq 30
    end
  end
end
