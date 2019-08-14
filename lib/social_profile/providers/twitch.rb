module SocialProfile
  module Providers
    class Twitch < Base
      def picture_url
        info 'image'
      end

      def profile_url
        info('urls')['Twitch']
      end
    end
  end
end
