module SocialProfile
  module Providers
    class Instagram < Base      
      
      def friends_count
        @friends_count ||= begin
          if auth_hash['extra'] && auth_hash['extra']['raw_info']
            count = auth_hash['extra']['raw_info']['counts']['followed_by']
            count.to_i
          end
        end
      end

      def picture_url
        @picture_url ||= begin
          url = info('image').split('?').shift()
          check_url([url, "type=large"].join('?'))
        end
      end

      def profile_url
        @profile_url ||= begin
          urls = info('urls')
          urls.nil? ? nil : urls['Instagram']
        end
      end
    end
  end  
end