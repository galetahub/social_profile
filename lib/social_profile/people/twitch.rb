module SocialProfile
  module People
    class Twitch < Person
      def username
        user['login']
      end

      def view_count
        user['view_count']
      end

      def followers_count
        follows(total: true)
      end

      def followings_count
        follows(direction: :from, total: true)
      end

      def followers(count: 100)
        follows(count: count)
      end

      def followings(count: 100)
        follows(direction: :from, count: count)
      end

      def user
        @user ||= get_json(client.get('helix/users', { id: uid })).dig('data', 0)
      end

      private

      def follows(direction: :to, count: 100, total: false)
        follow_id_key = direction.eql?(:to) ? 'from_id' : 'to_id'
        _follows, pagination_cursor = [], nil
        loop do
          body = get_json client.get('helix/users/follows', "#{direction}_id": uid, first: 100, after: pagination_cursor)
          return body['total'] if total

          pagination_cursor = body.dig('pagination', 'cursor')
          break if _follows.count >= count || !body['data']&.any?

          _follows.concat(body['data'])
        end

        _follows.map { |f| self.class.new(f[follow_id_key], access_token) }
      end

      def client
        @client ||= SocialProfile::HTTPParser.new('https://api.twitch.tv', nil, access_token: access_token).client
      end

      def get_json(response)
        JSON.parse response.body
      end
    end
  end
end
