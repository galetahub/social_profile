require 'spec_helper'

describe SocialProfile::People::Vkontakte do
  it "should be a Module" do
    SocialProfile::People.should be_a(Module)
  end

  context "vkontakte" do
    before(:each) do
      @user = SocialProfile::Person.get(:vkontakte, "2592709", "abc")

      stub_request(:get, "https://api.vk.com/method/users.get?access_token=abc&fields=counters&uids=2592709").
         to_return(:status => 200, :body => fixture('vkontakte/friends_count.json'))
      stub_request(:get, "https://api.vk.com/method/wall.get?access_token=abc&count=100&filter=owner&offset=0&owner_id=2592709").
         to_return(:status => 200, :body => fixture("vkontakte/last_posts.json"))
      stub_request(:get, "https://api.vk.com/method/likes.getList?access_token=abc&count=1000&item_id=655&offset=0&owner_id=2592709&type=post").
         to_return(:status => 200, :body => fixture("vkontakte/likes_post_655.json"))
      stub_request(:get, "https://api.vk.com/method/likes.getList?access_token=abc&count=1000&item_id=290498375&offset=0&owner_id=2592709&type=photo").
         to_return(:status => 200, :body => fixture("vkontakte/likes_photo_290498375.json"))
      stub_request(:get, "https://api.vk.com/method/wall.getComments?access_token=abc&count=100&need_likes=1&offset=0&owner_id=2592709&post_id=655&preview_length=0").
         to_return(:status => 200, :body => fixture("vkontakte/comments_post_655.json"))
      stub_request(:get, "https://api.vk.com/method/photos.getAllComments?access_token=abc&count=100&need_likes=1&offset=0&owner_id=2592709&uid=2592709").
         to_return(:status => 200, :body => fixture("vkontakte/comments_photos.json"))
    end

    it "should be a vkontakte profile" do
      @user.should be_a(SocialProfile::People::Vkontakte)
    end

    it "should response to friends_count" do
      @user.friends_count.should > 0
    end

    it "should response to last_posts" do
      @user.last_posts["items"].size.should == 100
    end

    it "should response to object_likes" do
      @user.object_likes("655")["items"].size.should == 7
      @user.object_likes("290498375", :type => "photo")["items"].size.should == 17
    end

    it "should response to post_comments" do
      @user.post_comments("655")["items"].size.should == 3
    end

    it "should response to photos_comments" do
      @user.photos_comments["items"].size.should == 100
    end
  end
end
