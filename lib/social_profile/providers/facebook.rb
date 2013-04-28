# encoding: utf-8
module SocialProfile
  module Providers
    class Facebook < Base
      # http://developers.facebook.com/docs/reference/api/#pictures
      #    
      def picture_url
        @picture_url ||= begin
          url = info('image').split('?').shift()
          check_url([url, "type=large"].join('?'))
        end
      end
      
      def profile_url
        @profile_url ||= begin
          urls = info('urls')
          urls.nil? ? nil : urls['Facebook']
        end
      end
      
      # 0 - unknown
      # 1 - female
      # 2 - male
      # Возвращаемые значения: 1 - женский, 2 - мужской, 0 - без указания пола. 
      def gender
        @gender ||= case extra('raw_info')['gender']
          when 'male' then 2
          when 'female' then 1
          else 0
        end
      end

      def birthday
        @birthday ||= begin
          Date.strptime(extra('raw_info')['birthday'],'%m/%d/%Y')
        rescue Exception => e
          nil
        end
      end
      
      protected
      
        def check_url(url)
          response = Utils.head(url, :follow_redirects => false)

          if response.code == 302 && response.headers['location']
            [response.headers['location']].flatten.first
          else
            url
          end
        end
      
    end
  end
end
