require "twitter"

module SocialProfile
  module People
    class Twitter < Person
      MAX_ATTEMPTS = 3

      # Get friends count
      def friends_count
        @friends_count ||= fetch_friends_count
      end

      def fetch_friends_count
        client.user.followers_count
      end

      # Get last limited tweets from user_timeline, max 200 by query
      #
      def last_posts(uid, options = {})
        params = { 
          :count => 200, 
          :exclude_replies => true, 
          :trim_user => true,
          :include_rts => false
        }

        params.merge!(options)

        with_atterms do 
          client.user_timeline(uid, params)  
        end     
      end

      def get_all_tweets(uid, options = {})
        collect_with_max_id do |max_id|
          options[:max_id] = max_id unless max_id.nil?
          last_posts(uid, options)
        end
      end

      def collect_with_max_id(collection=[], max_id=nil, &block)
        response = yield(max_id)
        collection += response
        response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
      end

      def with_atterms
        num_attempts = 0

        begin
          num_attempts += 1
          yield if block_given?
        rescue ::Twitter::Error::TooManyRequests => error
          if num_attempts <= MAX_ATTEMPTS
            # NOTE: Your process could go to sleep for up to 15 minutes but if you
            # retry any sooner, it will almost certainly fail with the same exception.
            sleep error.rate_limit.reset_in
            retry
          else
            raise
          end
        end
            
      end
      
      protected
      
        def client
          @client ||= ::Twitter::REST::Client.new do |config|
            config.consumer_key        = options[:api_key]
            config.consumer_secret     = options[:api_secret]
            config.access_token        = access_token
            config.access_token_secret = options[:token_secret]
          end
        end
    end
  end
end