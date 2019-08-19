require "social_profile/version"
require 'yaml'

module SocialProfile
  autoload :Utils, "social_profile/utils"
  autoload :Response, "social_profile/response"
  autoload :Person, "social_profile/person"
  autoload :RubyInstagramScraper, "social_profile/ruby-instagram-scraper"
  autoload :BrowserParser, 'social_profile/browser_parser'
  autoload :HTTPParser, 'social_profile/http_parser'
  autoload :AuthorizationError, 'social_profile/exceptions'
  autoload :ProfileInternalError, 'social_profile/exceptions'

  module Providers
    autoload :Base, "social_profile/providers/base"
    autoload :Facebook, "social_profile/providers/facebook"
    autoload :Vkontakte, "social_profile/providers/vkontakte"
    autoload :Twitter, "social_profile/providers/twitter"
    autoload :Instagram, "social_profile/providers/instagram"
    autoload :Odnoklassniki, "social_profile/providers/odnoklassniki"
    autoload :Google, "social_profile/providers/google"
    autoload :Linkedin, 'social_profile/providers/linkedin'
    autoload :Twitch, 'social_profile/providers/twitch'
    autoload :Telegram, 'social_profile/providers/telegram'
  end

  module People
    autoload :Facebook, "social_profile/people/facebook"
    autoload :Vkontakte, "social_profile/people/vkontakte"
    autoload :Twitter, "social_profile/people/twitter"
    autoload :Instagram, "social_profile/people/instagram"
    autoload :InstagramParser, "social_profile/people/instagram_parser"
    autoload :Google, "social_profile/people/google"
    autoload :Twitch, 'social_profile/people/twitch'
  end

  module BrowserParsers
    autoload :InstagramParser, 'social_profile/browser_parsers/instagram_parser'
    autoload :GmailParser, 'social_profile/browser_parsers/gmail_parser'
  end

  module HTTPParsers
    autoload :InstagramParser, 'social_profile/http_parsers/instagram_parser'
  end

  def self.get(auth_hash, options = {})
    provider = auth_hash["provider"].to_s.downcase if auth_hash && auth_hash["provider"]

    klass_str = "Providers::#{provider.capitalize}"
    klass = const_defined?(klass_str) ? const_get(klass_str) : Providers::Base

    klass.new(auth_hash, options)
  end

  def self.root_path
    @root_path ||= Pathname.new(File.dirname(File.expand_path('../', __FILE__)))
  end
end
