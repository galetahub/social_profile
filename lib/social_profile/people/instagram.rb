require "instagram"

module SocialProfile
  module People
    class Instagram < Person
      POSTS_COUNT = 100

      def last_posts(options={})
        limit = options[:limit] || POSTS_COUNT

        client.user_recent_media count: limit
      end

      protected
      
        def client
          ::Instagram.client(access_token: access_token)
        end
    end
  end
end