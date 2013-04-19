# encoding: utf-8
require 'spec_helper'

describe SocialProfile::People::Facebook do
  it "should be a Module" do
    SocialProfile::People.should be_a(Module)
  end

  context "facebook" do
    before(:each) do
      @user = SocialProfile::Person.get(:facebook, "100000730417342", "abc")
    end

    it "should be a facebook profile" do
      @user.should be_a(SocialProfile::People::Facebook)
    end
  end
end
