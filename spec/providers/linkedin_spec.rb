require 'spec_helper'

describe SocialProfile::Providers::Linkedin do
  let(:hash) { JSON.parse(fixture('linkedin/auth.json')) }
  let(:profile) { SocialProfile.get(hash) }

  it '#name' do
    expect(profile.name).to eq 'Oleksii Vykhor'
  end

  describe '#picture_url' do
    let(:picture_url) do
      'https://media.licdn.com/dms/image/C5603AQFR_BnUD5ItUg/profile-displayphoto-shrink_800_800/'\
        '0?e=1570665600&v=beta&t=4j_jLxMaja2APM8Ha4D349-SyCZTxyVwNjig-4V5lf8'
    end

    it { expect(profile.picture_url).to eq picture_url }
  end
end
