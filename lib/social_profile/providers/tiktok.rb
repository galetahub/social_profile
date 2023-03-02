# frozen_string_literal: true

module SocialProfile
  module Providers
    class Tiktok < Base
      def friends_count
        @friends_count ||= extra_info('follower_count').to_i
      end

      def nickname
        @nickname ||= extra_info('display_name')
      end

      def picture_url
        @picture_url ||= extra_info('avatar_url')
      end

      def likes_count
        @likes_count ||= extra_info('likes_count')
      end

      private

      def extra_info(key)
        auth_hash.dig('extra', 'raw_info', 'data', 'user', key)
      end
    end
  end
end
