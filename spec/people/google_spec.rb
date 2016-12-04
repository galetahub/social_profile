require 'spec_helper'

describe SocialProfile::People::Google do
  it "should be a Module" do
    SocialProfile::People::Google.should be_a(Module)
  end

  context "google" do
    before(:each) do
      @user = SocialProfile::Person.get(:google, "123456", "abc")

      stub_request(:get, "https://www.googleapis.com/youtube/v3/channels?mine=true&part=statistics").
        to_return(:status => 200, :body => fixture('google/channels.json'))
    end

    it "should be a google profile" do
      @user.should be_a(SocialProfile::People::Google)
    end

    it "should response to friends_count" do
      @user.friends_count.should == 2
    end
  end
end
