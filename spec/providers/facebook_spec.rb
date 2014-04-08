# encoding: utf-8
require 'spec_helper'

describe SocialProfile::Providers::Facebook do
  it "should be a Module" do
    SocialProfile::Providers.should be_a(Module)
  end

  context "facebook" do
    before(:each) do
      hash = {"provider"=>"facebook", "uid"=>"100000730417342", "info"=>{"nickname"=>"pavel.galeta", "email"=>"email@gmail.com", "name"=>"Pavel Galeta", "first_name"=>"Pavel", "last_name"=>"Galeta", "image"=>"http://graph.facebook.com/100000730417342/picture?type=square", "description"=>"введи в Google super_p", "urls"=>{"Facebook"=>"http://www.facebook.com/pavel.galeta"}, "location"=>"Kyiv, Ukraine", "verified"=>true}, "credentials"=>{"token"=>"AAAC1N4JHfIcBAIDYp0QLdyCMX9LenAS6KNDrGNZAOQ8bOYObHSg3tgxzvEVNLOTCZBOHDUCcHDxINgluKw52CLxMMZAxHaPXqAwZABMqhgZDZD", "expires_at"=>1369429974, "expires"=>true}, "extra"=>{"raw_info"=>{"id"=>"100000730417342", "name"=>"Pavel Galeta", "first_name"=>"Pavel", "last_name"=>"Galeta", "link"=>"http://www.facebook.com/pavel.galeta", "username"=>"pavel.galeta", "hometown"=>{"id"=>"108505112504762", "name"=>"Myronivka"}, "location"=>{"id"=>"111227078906045", "name"=>"Kyiv, Ukraine"}, "bio"=>"введи в Google super_p", "quotes"=>"Мир становится всё web'анутее и web'анутее ...", "work"=>[], "favorite_teams"=>[], "favorite_athletes"=>[], "education"=>[], "gender"=>"male", "email"=>"mail@gmail.com", "timezone"=>2, "locale"=>"en_US", "languages"=>[], "verified"=>true, "updated_time"=>"2013-03-24T21:02:30+0000"}}}
      @profile = SocialProfile.get(hash)
    end

    it "should be a facebook profile" do
      @profile.should be_a(SocialProfile::Providers::Facebook)
    end

    it "should parse profile" do
      @profile.name.should == "Pavel Galeta"
      @profile.email.should == "email@gmail.com"
      # @profile.picture_url.should == "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5.0-1/1116992_100000730417342_336985489_n.jpg"
      @profile.gender.should == 2
      @profile.profile_url.should == "http://www.facebook.com/pavel.galeta"
      @profile.works.should == []
      @profile.works?.should == true
    end
  end
end