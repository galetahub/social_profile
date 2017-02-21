module SocialProfile
  module People
    class InstagramParser < Person
      def last_posts
        RubyInstagramScraper.get_user_media_nodes(self.uid)['items']
      end

      def friends_count
        user['followed_by']['count']
      end

      def user
        RubyInstagramScraper.get_user(self.uid)
      end
    end
  end
end
