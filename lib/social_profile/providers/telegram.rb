module SocialProfile
  module Providers
    class Telegram < Base
      def picture_url
        info 'image'
      end
    end
  end
end
