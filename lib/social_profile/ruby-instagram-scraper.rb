require 'open-uri'
require 'json'

module SocialProfile
  module RubyInstagramScraper

    BASE_URL = "https://www.instagram.com"

    def self.search ( query )
      # return false unless query

      url = "#{BASE_URL}/web/search/topsearch/"
      params = "?query=#{ query }"

      JSON.parse( open( "#{url}#{params}" ).read )
    end

    def self.get_user_media_nodes ( username, max_id = nil )
      url = "#{BASE_URL}/#{ username }/media/"
      params = ""
      params = "?max_id=#{ max_id }" if max_id

      JSON.parse( open( "#{url}#{params}" ).read )
    end

    def self.get_user(username, options = {})
      json_path = "#{username}/?__a=1&__d=dis"

      body = if options[:client]
               options[:client].get(json_path).body
             else
               open(File.join(BASE_URL, json_path)).read
             end

      JSON.parse(body)['graphql']['user']
    end

    def self.get_tag_media_nodes ( tag, max_id = nil )
      url = "#{BASE_URL}/explore/tags/#{ tag }/?__a=1"
      params = ""
      params = "&max_id=#{ max_id }" if max_id

      JSON.parse( open( "#{url}#{params}" ).read )["tag"]["media"]["nodes"]
    end

    def self.get_media ( code )
      url = "#{BASE_URL}/p/#{ code }/?__a=1"
      params = ""

      JSON.parse( open( "#{url}#{params}" ).read )["graphql"]['shortcode_media']
    end

    def self.get_media_comments ( shortcode, count = 40, before = nil )
      params = before.nil?? "comments.last(#{ count })" : "comments.before( #{ before } , #{count})"
      url = "#{BASE_URL}/query/?q=ig_shortcode(#{ shortcode }){#{ params }\
        {count,nodes{id,created_at,text,user{id,profile_pic_url,username,\
        follows{count},followed_by{count},biography,full_name,media{count},\
        is_private,external_url,is_verified}},page_info}}"

      JSON.parse( open( url ).read )["comments"]
    end
  end
end
