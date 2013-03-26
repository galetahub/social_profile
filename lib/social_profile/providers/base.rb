# encoding: utf-8
require "date"

module SocialProfile
  module Providers
    class Base
      attr_reader :auth_hash
      
      def initialize(hash, options)
        @auth_hash = hash
        @options = options
      end

      def uid
        @uid ||= auth_hash['uid']  
      end

      def provider
        @provider ||= auth_hash['provider']
      end

      def name
        @name ||= info('name')
      end

      def first_name
        @first_name ||= (info('first_name') || name)
      end

      def last_name
        @last_name ||= info('last_name')
      end

      def nickname
        @nickname ||= info('nickname')
      end
      
      def info(key)
        if info? && !auth_hash['info'][key].blank?
          auth_hash['info'][key]
        end
      end
      
      def extra(key)
        if extra? && !auth_hash['extra'][key].blank?
          auth_hash['extra'][key]
        end
      end
      
      def extra?
        !auth_hash['extra'].blank?
      end
      
      def info?
        !auth_hash['info'].blank?
      end
      
      def avatar_url
        @avatar_url ||= info('image')
      end
      
      def city_name
        @city_name ||= begin
          loc = info('location')
          loc.nil? ? nil : loc.split(',').pop().strip
        end
      end
      
      def access_token
        @access_token ||= credentials['token']
      end
      
      def credentials
        @credentials ||= (auth_hash['credentials'] || {})
      end
      
      def profile_url
        nil
      end
      
      # Возвращаемые значения: 1 - женский, 2 - мужской, 0 - без указания пола.
      def gender
        0
      end
      
      def email
        @email ||= info('email')
      end

      def token_expires_at
        @token_expires_at ||= parse_datetime(credentials['expires_at'])
      end

      protected

        def parse_datetime(value)
          return nil if value.blank? || value.to_i.zero?
          Time.at(value.to_i).to_datetime
        end
    end
  end
end
