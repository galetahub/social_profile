module SocialProfile
  module HTTPParsers
    class InstagramParser < SocialProfile::HTTPParser
      def followers_usernames(username, attempts = 3, fetch_count: 1000, followers_count: 1000)
        raise SocialProfile::AuthorizationError, self.class unless logged_in?

        user_page = client.get("#{username}/").body
        followers, next_page_token = [], nil
        loop do
          response = client.get(followers_endpoint(user_id(username), query_hash(user_page), next_page_token))
          json = JSON.parse response.body
          edges = json.dig('data', 'user', 'edge_followed_by', 'edges')
          followers << edges.map do |edge|
            edge.dig('node', 'username')
          end
          followers.flatten!
          next_page_token = json.dig('data', 'user', 'edge_followed_by', 'page_info', 'end_cursor')
          next_page_token = CGI.escape(next_page_token) if next_page_token

          break if followers.count >= fetch_count || next_page_token.nil?
        end

        followers.uniq
      rescue SocialProfile::ProfileInternalError
        return [] if attempts.zero?

        followers_usernames(username, attempts - 1, fetch_count: fetch_count, followers_count: followers_count)
      end

      private

      def logged_in?
        !client.get.body[/not\-logged\-in/]
      end

      def followers_endpoint(user_id, query_hash, next_page_token = nil)
        after_part = next_page_token ? "%2C%22after%22%3A%22#{next_page_token}%22" : nil
        "graphql/query/?query_hash=#{query_hash}&"\
          "variables=%7B%22id%22%3A%22#{user_id}%22%2C%22include_reel%22%3Atrue%2C%22"\
          "fetch_mutual%22%3Afalse%2C%22first%22%3A24#{after_part}%7D"
      end

      def user_id(username)
        SocialProfile::RubyInstagramScraper.get_user(username, client: client)['id']
      end

      def query_hash(user_page)
        js_endpoint = user_page[/src\s*\=\s*(?:\'|\")([\w\W]{,100}Consumer\.js[\w\W]{,100}\.js)/, 1]
        raise SocialProfile::ProfileInternalError unless js_endpoint

        js_content = client.get(js_endpoint).body
        regex = /mutualUsers[\w\W]+?(?:var|const)\s*t\s*\=\s*\\?(?:\'|\")([A-z0-9]+?)(?:\'|\")\s*\,n/
        js_content[regex, 1]
      end
    end
  end
end
