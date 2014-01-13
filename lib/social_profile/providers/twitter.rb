module SocialProfile
  module Providers
    class Twitter < Base      
      def friends_count
        @friends_count ||= begin
          if auth_hash['extra'] && auth_hash['extra']['raw_info']
            count = auth_hash['extra']['raw_info']['followers_count']
            count.to_i
          end
        end
      end
    end
  end  
end
