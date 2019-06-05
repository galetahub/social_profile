# encoding: utf-8
require 'spec_helper'

describe SocialProfile::Providers::Facebook do
  it 'should be a Module' do
    expect(SocialProfile::Providers).to be_a Module
  end

  context 'facebook' do
    let(:hash) do
      {
        'provider' => 'facebook',
        'uid' => '100000730417342',
        'info' => {
          'nickname' => 'pavel.galeta',
          'email' => 'email@gmail.com',
          'name' => 'Pavel Galeta',
          'first_name' => 'Pavel',
          'last_name' => 'Galeta',
          'image' => 'http://graph.facebook.com/100000730417342/picture?type=square',
          'description' => 'введи в Google super_p',
          'urls' => { 'Facebook' => 'http://www.facebook.com/pavel.galeta' },
          'location' => 'Kyiv, Ukraine', 'verified' => true
        },
        'credentials' => {
          'token' => 'AAAC1N4JHfIcBAIDYp0QLdyCMX9LenAS6KNDrGNZAOQ8bOYObHSg3tgxzvEVNLOTCZBOHDUCcHDxINgluKw52CLxMMZAxHaPXqAwZABMqhgZDZD',
          'expires_at' => 1369429974, 'expires' => true
        },
        'extra' => {
          'raw_info' => {
            'id' => '100000730417342',
            'name' => 'Pavel Galeta',
            'first_name' => 'Pavel',
            'last_name' => 'Galeta',
            'link' => 'http://www.facebook.com/pavel.galeta',
            'username' => 'pavel.galeta',
            'hometown' => { 'id' => '108505112504762', 'name' => 'Myronivka' },
            'location' => {'id' => '111227078906045', 'name' => 'Kyiv, Ukraine' },
            'bio' => 'введи в Google super_p',
            'quotes' => "Мир становится всё web'анутее и web'анутее ...",
            'work' => [],
            'favorite_teams' => [],
            'favorite_athletes' => [],
            'education' => [],
            'gender' => 'male',
            'email' => 'mail@gmail.com',
            'timezone' => 2,
            'locale' => 'en_US',
            'languages' => [],
            'verified' => true,
            'updated_time' => '2013-03-24T21:02:30+0000'
          }
        }
      }
    end
    let(:profile) { SocialProfile.get(hash) }

    it 'should be a facebook profile' do
      expect(profile).to be_a described_class
    end

    it 'should parse profile' do
      expect(profile.name).to eq 'Pavel Galeta'
      expect(profile.email).to eq 'email@gmail.com'
      # @profile.picture_url.should == "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5.0-1/1116992_100000730417342_336985489_n.jpg"
      expect(profile.gender).to eq 2
      expect(profile.profile_url).to eq 'http://www.facebook.com/pavel.galeta'
      expect(profile.works).to be_empty
      expect(profile).to be_works
    end
  end
end
