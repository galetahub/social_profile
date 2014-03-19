require "twitter"

module SocialProfile
  module People
    class Twitter < Person

      # Get friends count
      def friends_count
        @friends_count ||= fetch_friends_count
      end

      def fetch_friends_count
        client.user.followers_count
      end
      
      protected
      
        def client
          @client ||= ::Twitter::REST::Client.new do |config|
            config.consumer_key        = options[:api_key]
            config.consumer_secret     = options[:api_secret]
            config.access_token        = access_token
            config.access_token_secret = options[:token_secret]
          end
        end
    end
  end
end