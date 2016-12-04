require 'google/apis/youtube_v3'

module SocialProfile
  module People
    class Google < Person
      # Get friends count
      #
      def friends_count
        @friends_count ||= channels.items.map { |item| item.statistics.subscriber_count.to_i }.sum
      end

      def channels
        @channels ||= client.list_channels('statistics', mine: true)
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
