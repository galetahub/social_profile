require 'spec_helper'

describe SocialProfile::People::Twitter do
  it "should be a Module" do
    SocialProfile::People.should be_a(Module)
  end

  context "twitter" do
    before(:each) do
      @user = SocialProfile::Person.get(:twitter, "123456", "abc", :api_key => "111", :api_secret => "222", :token_secret => "333")
      stub_request(:post, "https://api.twitter.com/oauth2/token").with(:body => {'grant_type' => 'client_credentials'}).
        to_return(:body => fixture("twitter/token.json"), :headers => {:content_type => 'application/json; charset=utf-8'})
      stub_request(:get, "https://api.twitter.com/1.1/account/verify_credentials.json").
        to_return(:body => fixture('twitter/auth.json'), :headers => {:content_type => 'application/json; charset=utf-8'})
      stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=false&screen_name=150587663&trim_user=true").
        to_return(:status => 200, :body => fixture('twitter/last_posts.json'))
    end

    it "should be a twitter profile" do
      @user.should be_a(SocialProfile::People::Twitter)
    end

    it "should response to friends_count" do
      @user.friends_count.should == 69
    end

    it "should response to last_posts" do
      posts = @user.last_posts("150587663")

      retweets_count = posts.sum(&:retweet_count)
      retweets_count.should == 9
      posts.size.should == 107

      # average user reach
      (@user.friends_count + (retweets_count * 100) / posts.size).should == 77
    end

    it "should response to get_all_tweets" do
      posts = @user.last_posts("150587663")

      posts.sum(&:retweet_count).should == 9
      posts.size.should == 107
    end
  end
end