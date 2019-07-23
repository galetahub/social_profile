module SocialProfile
  module People
    class InstagramParser < Person
      def username
        user['username']
      end

      def last_posts
        # RubyInstagramScraper.get_user_media_nodes(self.uid)['items']
        user['edge_owner_to_timeline_media'].try(:[], 'edges')
      end

      def get_post(post_uid)
        RubyInstagramScraper.get_media(post_uid)
      end

      def friends_count
        user['edge_followed_by']['count']
      end

      def subscriptions_count
        user['edge_follow']['count']
      end

      # When user has no avatar, new url is generated per each request.
      # To be sure that user did not change his avatar at the same time as we sent request,
      # we compare 4 urls.
      def has_avatar?
        key = 'profile_pic_url'
        user[key].present? && [user[key], user[key], user[key], user[key]].uniq.one?
      end

      def friends(count: 200)
        friends = parser.followers_usernames(username,
                                             fetch_count: count,
                                             followers_count: friends_count)
        friends.map { |uid| self.class.new(uid, nil) }
      end

      def user
        @options[:client] = parser.client unless @options[:client]

        RubyInstagramScraper.get_user(self.uid, @options)
      end

      private

      def parser
        url = RubyInstagramScraper::BASE_URL
        return BrowserParsers::InstagramParser.new(url, cookies: options[:cookies]) if @options[:browser_parsing]

        cookies = @options[:cookies] || ENV['INSTAGRAM_COOKIES_PATH']
        SocialProfile::HTTPParsers::InstagramParser.new(url, cookies, @options)
      end
    end
  end
end
