require 'spec_helper'

describe SocialProfile::People::Linkedin do
  let(:uid) { 'UUiKjtZXr-' }
  let(:profile) { SocialProfile::Person.get(:linkedin, uid, 'token') }

  before do
    stub_request(:get, 'https://api.linkedin.com/v2/me').
      to_return(status: 200, body: fixture('linkedin/user.json'))
    stub_request(:get, "https://api.linkedin.com/v2/connections/urn:li:person:#{uid}").
      to_return(status: 200, body: fixture('linkedin/connection_size.json'))
  end

  it 'receives username (vanityName)' do
    expect(profile.username).to eq 'oleksii-vykhor-935aaa156'
  end

  it 'receives head line' do
    expect(profile.head_line).to eq 'ruby dev'
  end

  it 'receives followers count' do
    expect(profile.followers_count).to eq 46
  end

  it 'receives profile url' do
    expect(profile.profile_url).to eq 'https://www.linkedin.com/in/oleksii-vykhor-935aaa156'
  end
end
