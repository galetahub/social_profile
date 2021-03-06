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
      
      def nickname
        @nickname ||= info('username')
      end
    end
  end  
end
