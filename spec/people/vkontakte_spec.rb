require 'spec_helper'

describe SocialProfile::People::Vkontakte do
  it "should be a Module" do
    SocialProfile::People.should be_a(Module)
  end

  context "vkontakte" do
    before(:each) do
      @user = SocialProfile::Person.get(:vkontakte, "123456789", "abc")
      stub_request(:get, "https://api.vk.com/method/users.get?access_token=abc&fields=counters&uids=123456789").
         to_return(:status => 200, :body => File.read(SocialProfile.root_path.join('spec/mock_json/vkontakte/friends_count.json')))
    end

    it "should be a vkontakte profile" do
      @user.should be_a(SocialProfile::People::Vkontakte)
    end

    it "should response to friends_count" do
      @user.friends_count.should > 0
    end
  end
end
