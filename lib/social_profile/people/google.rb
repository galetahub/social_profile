require 'google/apis/youtube_v3'

module SocialProfile
  module People
    class Google < Person
      PART = 'snippet,brandingSettings,statistics,topicDetails'.freeze

      # Get friends count
      #
      def friends_count
        @friends_count ||= channels.items.map do |item|
          (item.statistics.subscriber_count || item.statistics.subscriberCount).to_i
        end.sum
      end

      def channels
        return @channels if @channels

        opts = if options[:channel_id]
          # This is for subscription channels
          { id: options[:channel_id], max_results: 1 }
        else
          { mine: true }
        end

        @channels ||= client.list_channels(PART, opts)
      end

      def subscription_channels(count: 10)
        options = { channel_id: channel.id,
                    part: :snippet,
                    id_chain: [:snippet, :resource_id, :channel_id] }
        @subscription_channels ||= create_channels list_of_ids_by(:subscriptions, count, options)
      end

      def channel_title
        channel.snippet.title
      end

      def channel_country
        client.list_i18n_regions('snippet').items.detect do |item|
          item.id == channel.snippet.country
        end&.snippet&.name
      end

      def channel_categories
        channel.topic_details.topic_categories
      end

      def channel_keywords
        keywords = channel.branding_settings.channel.keywords.to_s.split(/\"([\w\W]+?)\"|\s/)
        keywords.select(&:present?)
      end

      def channel_video_count
        channel.statistics.video_count&.to_i
      end

      def channel_view_count
        channel.statistics.view_count&.to_i
      end

      def last_like_count(count: 10)
        last_videos_statistics(count)[:likes]
      end

      def last_comment_count(count: 10)
        last_videos_statistics(count)[:comments]
      end

      def last_view_count(count: 10)
        last_videos_statistics(count)[:views]
      end

      protected

        def client
          @client ||= options[:client]
          return @client if @client

          @client = ::Google::Apis::YoutubeV3::YouTubeService.new
          @client.authorization = access_token

          @client
        end

      private

        def list_of_ids_by(target, count, options = {})
          [:part, :id_chain].each do |key|
            raise ArgumentError, "missing keyword argument #{key}" unless options[key]
          end

          options[:max_results] = count < 50 ? count : 50
          id_chain = options.delete(:id_chain)
          part = options.delete(:part)
          ids = []
          results = []
          loop do
            options[:page_token] = results.try(:next_page_token)
            results = client.try("list_#{target}", part, options)
            ids.concat(results.items.map { |i| try_chain(i, id_chain) }).uniq!

            break if ids.count >= count || results.items.count < options[:max_results]
          end

          ids.compact
        end

        def create_channels(channel_ids)
          channel_ids.map do |channel_id|
            self.class.new(nil, access_token, client: client, channel_id: channel_id)
          end
        end

        def last_videos_statistics(count)
          return @last_videos_statistics if @last_videos_statistics.try(:[], :count).try(:eql?, count)

          @last_videos_statistics = { count: count, comments: 0, likes: 0, views: 0 }
          video_ids(count).each do |id|
            statistics = client.list_videos('statistics', id: id).items.first.statistics
            @last_videos_statistics[:comments] += statistics.comment_count.to_i
            @last_videos_statistics[:likes] += statistics.like_count.to_i
            @last_videos_statistics[:views] += statistics.view_count.to_i
          end

          @last_videos_statistics
        end

        def video_ids(count)
          options = { channel_id: channel.id,
                      part: 'contentDetails',
                      id_chain: [:content_details, :upload, :video_id] }
          @video_ids = list_of_ids_by(:activities, count, options)
        end

        def try_chain(obj, methods)
          methods.inject(obj) { |result, method| result.try(method) }
        end

        def channel
          channels.items.first
        end
    end
  end
end
