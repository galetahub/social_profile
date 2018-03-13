module SocialProfile
  module People
    class InstagramParser < Person
      def last_posts
        # RubyInstagramScraper.get_user_media_nodes(self.uid)['items']
        user['edge_owner_to_timeline_media'].try(:[], 'edges')
      end

      def friends_count
        user['edge_followed_by']['count']
      end

      def user
        RubyInstagramScraper.get_user(self.uid)
      end
    end
  end
end
