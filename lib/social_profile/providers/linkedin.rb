module SocialProfile
  module Providers
    class Linkedin < Base
      def name
        "#{info('first_name')} #{info('last_name')}"
      end

      def picture_url
        info 'picture_url'
      end
    end
  end
end
