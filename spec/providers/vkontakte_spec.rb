# encoding: utf-8
require 'spec_helper'

describe SocialProfile::Providers::Vkontakte do
  it "should be a Module" do
    SocialProfile::Providers.should be_a(Module)
  end

  context "vkontakte" do
    before(:each) do
      hash = {"info"=>{"name"=>"Павел Галета", "location"=>"Ukraine, Kiev", "urls"=>{"Vkontakte"=>"http://vkontakte.ru/id2592709"}, "nickname"=>"", "birth_date"=>"10.3.1987", "last_name"=>"Галета", "image"=>"http://cs10901.vkontakte.ru/u2592709/e_f8b6e3b9.jpg", "first_name"=>"Павел"}, "uid"=>2592709, "credentials"=>{"token"=>"7a1cfdd37a3b72167a3b7216ac7a1347bde7a3b7a3a7216c95a735a210be6d4"}, "extra"=>{"raw_info"=>{"timezone"=>2, "sex"=>"2", "photo_big"=>"http://cs10901.vkontakte.ru/u2592709/a_d8f124ce.jpg"}}, "provider"=>"vkontakte"}
      @profile = SocialProfile.get(hash)
    end

    it "should be a facebook profile" do
      @profile.should be_a(SocialProfile::Providers::Vkontakte)
    end

    it "should parse profile" do
      @profile.name.should == "Павел Галета"
      @profile.picture_url.should == "http://cs10901.vkontakte.ru/u2592709/a_d8f124ce.jpg"
      @profile.gender.should == 2
      @profile.profile_url.should == "http://vkontakte.ru/id2592709"
    end
  end
end