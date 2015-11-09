require 'spec_helper'

describe SocialProfile::People::Instagram do
  it "should be a Module" do
    SocialProfile::People.should be_a(Module)
  end

  context "instagram" do
    before(:each) do
      @user = SocialProfile::Person.get(:instagram, "123456", "abc")

      stub_request(:get, "https://api.instagram.com/v1/users/self/media/recent.json?access_token=abc&count=100").
        to_return(:status => 200, :body => fixture('instagram/last_posts.json'))
    end

    it "should be a instagram profile" do
      @user.should be_a(SocialProfile::People::Instagram)
    end

    it "should response to last_posts" do
      posts = @user.last_posts

      posts.size.should == 4
      posts.first.likes["count"].should == 6
    end
  end
end