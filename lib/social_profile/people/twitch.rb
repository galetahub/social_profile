module SocialProfile
  module People
    class Twitch < Person
      BASE_URL = 'https://api.twitch.tv'.freeze
      AUTH_TYPES = { helix: 'Bearer', kraken: 'OAuth' }.freeze
      API_VERSIONS = %i[helix kraken].freeze

      def initialize(uid, access_token, options = {})
        @api_version = options[:api_version].eql?(:helix) ? :helix : :kraken
        super
      end

      API_VERSIONS.each do |api_version|
        define_method "#{api_version}?" do
          @api_version == api_version
        end
      end

      def username
        user['login'] || user['name']
      end

      def picture_url
        user['profile_image_url'] || user['logo']
      end

      def last_videos
        channel_videos['videos'] || []
      end

      def status
        user['status']
      end

      def game
        user['game']
      end

      def description
        user['description']
      end

      def video_count
        channel_videos['_total']
      end

      def view_count
        user['view_count'] || user['views']
      end

      def followers_count
        user['followers'] || follows(total: true)
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
        if helix?
          @user ||= get_json(helix_client.get('helix/users', { id: uid })).dig('data', 0)
        else
          @user ||= get_json(kraken_client.get("kraken/channels/#{uid}"))
        end
      end

      private

      def follows(direction: :to, count: 100, total: false)
        follow_id_key = direction.eql?(:to) ? 'from_id' : 'to_id'
        _follows, pagination_cursor = [], nil
        loop do
          body = get_json helix_client.get('helix/users/follows', "#{direction}_id": uid, first: 100, after: pagination_cursor)
          return body['total'] if total

          pagination_cursor = body.dig('pagination', 'cursor')
          break if _follows.count >= count || !body['data']&.any?

          _follows.concat(body['data'])
        end

        _follows.map { |f| self.class.new(f[follow_id_key], access_token, @options) }
      end

      def channel_videos
        return {} unless kraken?

        @channel_videos ||= get_json kraken_client.get("kraken/channels/#{uid}/videos", limit: 100)
      end

      %i[helix kraken].each do |method|
        client_name = "#{method}_client"
        define_method client_name do
          _client = instance_variable_get("@#{client_name}")
          return _client if _client

          accept_header = method.eql?(:kraken) ? 'application/vnd.twitchtv.v5+json' : nil
          options = { access_token: access_token, auth_type: AUTH_TYPES[method], accept: accept_header }
          instance_variable_set(
            "@#{client_name}",
            SocialProfile::HTTPParser.new(BASE_URL, uid, options).client)
        end
      end

      def get_json(response)
        JSON.parse response.body
      end
    end
  end
end
