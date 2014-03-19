require 'spec_helper'

describe SocialProfile::People::Twitter do
  it "should be a Module" do
    SocialProfile::People.should be_a(Module)
  end

  context "twitter" do
    before(:each) do
      @user = SocialProfile::Person.get(:twitter, "123456", "abc")
      stub_request(:post, "https://api.twitter.com/oauth2/token").with(:body => {'grant_type' => 'client_credentials'}).
        to_return(:body => fixture("twitter/token.json"), :headers => {:content_type => 'application/json; charset=utf-8'})
      stub_request(:get, "https://api.twitter.com/1.1/account/verify_credentials.json").
        to_return(:body => fixture('twitter/auth.json'), :headers => {:content_type => 'application/json; charset=utf-8'})
    end

    it "should be a twitter profile" do
      @user.should be_a(SocialProfile::People::Twitter)
    end

    it "should response to friends_count" do
      @user.friends_count.should == 4051
    end
  end
end