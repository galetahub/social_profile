# encoding: utf-8
require 'spec_helper'

describe SocialProfile::Providers::Vkontakte do
  it "should be a Module" do
    SocialProfile::Providers.should be_a(Module)
  end

  context "vkontakte with old response" do
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

  context "vkontakte with new response" do
    before(:each) do
      hash = { "provider"=>"vkontakte", "uid"=>"2592709", 
        "info"=>{"name"=>"Павел Галета", "nickname"=>"super_p", "first_name"=>"Павел", "last_name"=>"Галета", 
          "image"=>"http://cs11376.vk.me/u2592709/e_a3716437.jpg", 
          "location"=>"Украина, Киев", 
          "urls"=>{"Vkontakte"=>"http://vk.com/pavel.galeta"}}, 
          "credentials"=>{"token"=>"4b349b337f9ee42d4e3c2351fba07075f0d9ef7998150b2bd58571b4d329bc72aa4f3bea3e8328c409ac1202303eb", 
            "expires_at"=>1399544280, "expires"=>true}, 
            "extra"=>{"raw_info"=>{"id"=>2592709, "first_name"=>"Павел", "last_name"=>"Галета", "sex"=>2,
             "nickname"=>"super_p", "screen_name"=>"pavel.galeta", "bdate"=>"10.3.1987", "city"=>314, 
             "country"=>2, "photo_50"=>"http://cs11376.vk.me/u2592709/e_a3716437.jpg", 
             "photo_100"=>"http://cs11376.vk.me/u2592709/d_847b328d.jpg", 
             "photo_200_orig"=>"http://cs11376.vk.me/u2592709/a_1e6cab29.jpg", "online"=>0}}}

      @profile = SocialProfile.get(hash)
    end

    it "should be a facebook profile" do
      @profile.should be_a(SocialProfile::Providers::Vkontakte)
    end

    it "should parse profile" do
      @profile.name.should == "Павел Галета"
      @profile.picture_url.should == "http://cs11376.vk.me/u2592709/a_1e6cab29.jpg"
      @profile.gender.should == 2
      @profile.profile_url.should == "http://vk.com/pavel.galeta"
    end
  end
end