# frozen_string_literal: true

module SocialProfile
  module People
    class Tiktok < Person
      POSTS_COUNT = 20
      USER_FIELDS = %w[open_id union_id avatar_url display_name bio_description follower_count
                       following_count likes_count profile_deep_link].freeze
      VIDEO_FIELDS = %w[id create_time video_description title embed_html embed_link like_count
                        comment_count share_count view_count].freeze

      def username
        user['display_name']
      end

      def followers_count
        user['follower_count']
      end

      def profile_url
        user['profile_deep_link']
      end

      def likes_count
        user['likes_count']
      end

      def bio
        user['bio_description']
      end

      def avatar_url
        user['avatar_url']
      end

      def user
        @user ||= get_json(client.get('/v2/user/info/', fields: USER_FIELDS.join(',')).body)['user']
      end

      def videos
        @videos ||= get_json(client.post("/v2/video/list/?fields=#{VIDEO_FIELDS.join(',')}",
                                         "{\"max_count\": #{POSTS_COUNT}}",
                                         'Content-Type' => 'application/json').body)['videos']
      end

      private

      def client
        @client ||= SocialProfile::HTTPParser.new('https://open.tiktokapis.com',
                                                  nil,
                                                  access_token: access_token).client
      end

      def get_json(json_str)
        JSON.parse(json_str)['data']
      end
    end
  end
end
