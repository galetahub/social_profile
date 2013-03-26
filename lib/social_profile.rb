# encoding: utf-8
require "social_profile/version"

module SocialProfile
  autoload :Utils, "social_profile/utils"
  autoload :Response, "social_profile/response"

  module Providers
    autoload :Base, "social_profile/providers/base"
    autoload :Facebook, "social_profile/providers/facebook"
    autoload :Vkontakte, "social_profile/providers/vkontakte"
  end
    
  def self.get(auth_hash, options = {})
    provider = auth_hash["provider"].to_s.downcase if auth_hash && auth_hash["provider"]
    
    klass = case provider
      when "facebook" then Providers::Facebook
      when "vkontakte" then Providers::Vkontakte
      else Providers::Base
    end
    
    klass.new(auth_hash, options)
  end
end
