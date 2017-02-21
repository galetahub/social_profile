require 'google/apis/youtube_v3'
require 'json'

module SocialProfile
  module People
    class Google < Person
      # Get friends count
      #
      def friends_count
        @friends_count ||= channels.items.map do |item|
          (item.statistics.subscriber_count || item.statistics.subscriberCount).to_i
        end.sum
      end

      def channels
        return @channels if @channels

        _channels = client.list_channels('statistics', mine: true)

        @channels = if _channels.respond_to?(:items)
          _channels
        elsif _channels.is_a?(String)
          JSON.parse(_channels, object_class: OpenStruct)
        end

        @channels
      end

      protected

        def client
          return @client if @client

          @client = ::Google::Apis::YoutubeV3::YouTubeService.new
          @client.authorization = access_token

          @client
        end
    end
  end
end
