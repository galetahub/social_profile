require 'spec_helper'

describe SocialProfile::People::InstagramParser do
  context "instagram parser" do
    before(:each) do
      @user = SocialProfile::Person.get(:instagram_parser, "pavel_galeta", nil)
      @post_uid = 'BgTecbzDo2UB3AvPHBV9GNKriGiUYFDow_RP-o0'

      stub_request(:get, "https://www.instagram.com/pavel_galeta/media/").
        to_return(:status => 200, :body => fixture('instagram_parser/media.json'))
      stub_request(:get, "https://www.instagram.com/pavel_galeta/?__a=1").
        to_return(:status => 200, :body => fixture('instagram_parser/user.json'))
      stub_request(:get, "https://www.instagram.com/p/#{@post_uid}/?__a=1").
        to_return(:status => 200, :body => fixture('instagram_parser/post.json'))
    end

    it "should be a instagram profile" do
      @user.should be_a(SocialProfile::People::InstagramParser)
    end

    it "should response to last_posts" do
      posts = @user.last_posts

      expect(posts.size).to eq(12)
    end

    it "should response to user" do
      user = @user.user

      expect(user['username']).to eq('pavel_galeta')
      expect(user['id']).to eq('31973911')
    end

    it "should response to friends_count" do
      expect(@user.friends_count).to eq(102)
    end

    it "should response to get_post" do
      post = @user.get_post(@post_uid)

      expect(post['shortcode']).to eq(@post_uid)
      expect(post['edge_media_to_comment']['count']).to eq(2)
      expect(post['edge_media_preview_like']['count']).to eq(7)
      expect(post['taken_at_timestamp']).to eq(1521031947)
    end
  end
end
