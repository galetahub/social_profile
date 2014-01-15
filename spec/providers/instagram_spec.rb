require 'spec_helper'

describe SocialProfile::Providers::Instagram do
  it "should be a Module" do
    SocialProfile::Providers.should be_a(Module)
  end

  context "instagram" do
    before(:each) do
      hash = {"provider" => "instagram","uid" => "31973911","info" => {"nickname" => "pavel_galeta","name" => "pavel galeta","location" => "Anytown, USA","image" => "http://si0.twimg.com/sticky/default_profile_images/default_profile_2_normal.png","description" => "a very normal guy.","urls" => {"Website" => nil,"Twitter" => "https://twitter.com/johnqpublic"}},"credentials" => {"token" => "a1b2c3d4...", "secret" => "abcdef1234"},"extra" => {"access_token" => "", "raw_info" => {"username" => "pavel_galeta", "bio" => "", "website" => "", "profile_picture" => "http://images.ak.instagram.com/profiles/anonymousUser.jpg", "full_name" => "pavel galeta", "counts" =>  { "media" => 62, "followed_by" => 30, "follows" => 34}, "id" => "31973911"}}}
      @profile = SocialProfile.get(hash)
    end

    it "should be a instagram profile" do
      @profile.should be_a(SocialProfile::Providers::Instagram)
    end

    it "should parse profile" do
      @profile.name.should == "pavel galeta"
      @profile.friends_count.should == 30
    end
  end
end