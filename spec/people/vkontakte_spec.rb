# encoding: utf-8
require 'spec_helper'

describe SocialProfile::People::Vkontakte do
  it "should be a Module" do
    SocialProfile::People.should be_a(Module)
  end

  context "facebook" do
    before(:each) do
      @user = SocialProfile::Person.get(:vkontakte, "123456789", "abc")
    end

    it "should be a facebook profile" do
      @user.should be_a(SocialProfile::People::Vkontakte)
    end
  end
end
