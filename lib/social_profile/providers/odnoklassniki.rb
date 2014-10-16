# encoding: utf-8

module SocialProfile
  module Providers
    class Odnoklassniki < Base
      # http://developers.facebook.com/docs/reference/api/#pictures
      #    
      def picture_url
        @picture_url ||= begin
          url = info('image').gsub("photoType=4", "photoType=3")
          check_url(url)
        end
      end
      
      def profile_url
        @profile_url ||= begin
          urls = info('urls')
          urls.nil? ? nil : urls['Odnoklassniki']
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

      def city_name
        @city_name ||= begin
          location('city')
        end
      end

      def location?
        raw_info? && extra('raw_info')['location'] && extra('raw_info')['location'].is_a?(Hash)
      end

      def location(key)
        if location? && Utils.exists?(extra('raw_info')['location'][key])
          extra('raw_info')['location'][key]
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
      
        def raw_info?
          extra('raw_info') && extra('raw_info').is_a?(Hash)
        end
    end
  end
end
