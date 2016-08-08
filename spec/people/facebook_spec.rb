require 'spec_helper'

describe SocialProfile::People::Facebook do
  it "should be a Module" do
    SocialProfile::People.should be_a(Module)
  end

  context "facebook" do
    before :all do
      # FbGraph.debug!
    end

    before(:each) do
      @user = SocialProfile::Person.get(:facebook, "100000730417342", "abc")
    end

    it "should be a facebook profile" do
      @user.should be_a(SocialProfile::People::Facebook)
    end

    it "should response to friends_count" do
      stub_request(:get, "https://graph.facebook.com/v2.3/me/friends?limit=1").
         to_return(:status => 200, :body => fixture("facebook/friends_count.json"))

      @user.friends_count.should == 328
    end

    it "should response to followers_count" do
      @user.followers_count.should == 0
    end

    it "should response to followers without limits (without fetch_all)" do
      @user.followers.size.should == 0
    end

    it "should response to followers without limits (with fetch_all)" do
      @user.followers(:fetch_all => true).size.should == 0
    end

    it "should response to followers list with limits" do
      @user.followers(:limit => 5, :fetch_all => true).size.should == 0
    end

    it "should response to first_post_exists?" do
      @user.first_post_exists?(2011).should == nil
    end

    it "should response to last_posts" do
      fields = SocialProfile::People::Facebook::LAST_POSTS_FIELDS.join(",")

      stub_request(:get, "https://graph.facebook.com/v2.3/me/feed?fields=#{fields}&limit=600").
         to_return(:status => 200, :body => fixture("facebook/last_posts.json"))

      posts = @user.last_posts(600)

      posts.should be_a(Array)
      posts.size.should == 239
    end

    it "should response to last_posts by days (with 3 request to facebook api)" do
      fields = SocialProfile::People::Facebook::LAST_POSTS_FIELDS.join(",")
      fields2 = fields.gsub('.fields(created_time)', '')

      stub_request(:get, "https://graph.facebook.com/v2.3/me/feed?fields=#{fields}&limit=5").
         to_return(:status => 200, :body => fixture("facebook/last_5_posts.json"))
      stub_request(:get, "https://graph.facebook.com/v2.3/me/feed?fields=#{fields2}&limit=5&until=1394475325").
         to_return(:status => 200, :body => fixture("facebook/last_5_posts_page_2.json"))
      stub_request(:get, "https://graph.facebook.com/v2.3/me/feed?fields=#{fields2}&limit=5&until=1394439420").
         to_return(:status => 200, :body => fixture("facebook/last_5_posts_page_3.json"))

      posts = @user.last_post_by_days(10, :limit => 5, :date_end => DateTime.new(2014, 3, 15))

      posts.should be_a(Array)
      posts.size.should == 13
    end

    it "should get big data from last_posts" do
      fields = ["comments.limit(1000).fields(created_time,from).summary(true)",
                "likes.limit(1000).fields(id).summary(true)",
                "shares",
                "status_type"]

      stub_request(:get, "https://graph.facebook.com/v2.3/me/feed?fields=#{fields.join(',')}&limit=1000").
         to_return(:status => 200, :body => fixture("facebook/last_posts_big.json"))
      stub_request(:get, "https://graph.facebook.com/v2.3/me/feed?fields=#{fields.join(',')}&limit=1000&until=1394789304").
         to_return(:status => 200, :body => fixture("facebook/last_posts_big2.json"))

      posts = @user.last_post_by_days(30, :limit => 1000, :date_end => DateTime.new(2014, 4, 6), :fields => fields)

      posts.should be_a(Array)
      posts.size.should == 56
      posts.select {|p| p.raw_attributes["status_type"] == "shared_story"}.size.should == 13
    end

    it "should get friends list" do
      stub_request(:get, "https://graph.facebook.com/v2.3/me/friends?limit=100000").
         to_return(:status => 200, :body => fixture("facebook/friends.json"))

      friends = @user.friends(:limit => 100000)

      friends.should be_a(Array)
      friends.size.should == 4343
    end

    it "should get mutual friends" do
      mutual_friends = @user.mutual_friends

      mutual_friends.should be_a(Hash)
      mutual_friends.size.should == 0
    end
  end
end
