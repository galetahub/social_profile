require 'spec_helper'

describe SocialProfile::People::Facebook do
  it "should be a Module" do
    SocialProfile::People.should be_a(Module)
  end

  context "facebook" do
    before :all do 
      # stub = stub_request(:get, FbGraph::Query.new(query).endpoint).with(
      #   :query => {:q => query, :access_token => "abc"}, 
      #   :headers => {"Host" => 'graph.facebook.com'}
      # ).to_return(
      #   :body => '{"data": [{"friend_count": 230}]}'
      # )

      # FbGraph.debug!
    end

    before(:each) do
      @user = SocialProfile::Person.get(:facebook, "100000730417342", "abc")
    end

    it "should be a facebook profile" do
      @user.should be_a(SocialProfile::People::Facebook)
    end

    it "should response to friends_count" do
      mock_fql SocialProfile::People::Facebook::FRIENDS_FQL, SocialProfile.root_path.join('spec/mock_json/facebook/friends_count.json'), :access_token => "abc" do
        @user.friends_count.should > 0
      end
    end

    it "should response to first_post_exists?" do
      _sql = SocialProfile::People::Facebook::FIRST_POST_FQL.gsub('{date}', '1293832800')

      mock_fql _sql, SocialProfile.root_path.join('spec/mock_json/facebook/first_post.json'), :access_token => "abc" do
        @user.first_post_exists?(2011).should > 0
      end
    end

    it "should response to last_posts" do
      fields = SocialProfile::People::Facebook::LAST_POSTS_FIELDS.join(",")

      stub_request(:get, "https://graph.facebook.com/me/feed?access_token=abc&fields=#{fields}&limit=600").
         to_return(:status => 200, :body => fixture("facebook/last_posts.json"))

      posts = @user.last_posts(600)

      posts.should be_a(Array)
      posts.size.should == 239
    end

    it "should response to last_posts by days (with 3 request to facebook api)" do
      fields = SocialProfile::People::Facebook::LAST_POSTS_FIELDS.join(",")
      fields2 = fields.gsub('.fields(created_time)', '')

      stub_request(:get, "https://graph.facebook.com/me/feed?access_token=abc&fields=#{fields}&limit=5").
         to_return(:status => 200, :body => fixture("facebook/last_5_posts.json"))
      stub_request(:get, "https://graph.facebook.com/me/feed?access_token=abc&fields=#{fields2}&limit=5&until=1394475325").
         to_return(:status => 200, :body => fixture("facebook/last_5_posts_page_2.json"))
      stub_request(:get, "https://graph.facebook.com/me/feed?access_token=abc&fields=#{fields2}&limit=5&until=1394439420").
         to_return(:status => 200, :body => fixture("facebook/last_5_posts_page_3.json"))

      posts = @user.last_post_by_days(10, :limit => 5, :date_end => DateTime.new(2014, 3, 15))

      posts.should be_a(Array)
      posts.size.should == 13
    end

    it "should get big data from last_posts" do
      fields = ["comments.limit(1000).fields(created_time,from).summary(true)",
                "likes.limit(1000).fields(id).summary(true)",
                "created_time", 
                "shares"]

      stub_request(:get, "https://graph.facebook.com/me/feed?access_token=abc&fields=#{fields.join(',')}&limit=1000").
         to_return(:status => 200, :body => fixture("facebook/last_posts_big.json"))

      posts = @user.last_posts(1000, :fields => fields)

      posts.should be_a(Array)
      posts.size.should == 44
    end

    it "should get friends list" do
      stub_request(:get, "https://graph.facebook.com/me/friends?access_token=abc&limit=100000").
         to_return(:status => 200, :body => fixture("facebook/friends.json"))

      friends = @user.friends(:limit => 100000)

      friends.should be_a(Array)
      friends.size.should == 4343
    end
  end
end
