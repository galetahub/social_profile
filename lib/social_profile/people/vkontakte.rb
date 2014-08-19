require "vkontakte"
require "httpclient"
require "multi_json"

module SocialProfile
  module People
    class Vkontakte < Person
      # Find album by id
      def fetch_album(album_id)
        response = user.photos.getAlbums(:aids => album_id)
        Album.new(response, user)
      end
      
      # Create new album id
      def album!(options = {})
        response = user.photos.createAlbum(:title => options[:name], :description => options[:message])
        Album.new(response, user)
      end

      # Get friends count
      def friends_count
        @friends_count ||= fetch_friends_count
      end

      def fetch_friends_count
        response = user.fetch(:fields => "counters")
        response = response.first if response.is_a?(Array)

        return nil unless response.is_a?(Hash)

        counters = response["counters"] 
        return nil if counters["friends"].blank? && counters["followers"].blank?

        counters["friends"].to_i + counters["followers"].to_i
      end

      # Get last limited posts from user_timeline, max 100 by query
      #
      def last_posts(options = {})
        days = options.delete(:days)
        date_end = options.delete(:date_end)

        params = { 
          :owner_id => user.identifier,
          :count => 100, 
          :filter => "owner", 
          :offset => 0
        }

        params.merge!(options)

        response = user.wall.get(params)
        _items = response["items"]

        if days
          date = (date_end || Time.now) - days.days
          iteration = (response["count"].to_i / _items.size.to_f).ceil
          last_date = _items.last ? Time.at(_items.last["date"].to_i).to_datetime : nil

          iteration.times do |index|
            next if index == 0

            params[:offset] += params[:count]
            _items += user.wall.get(params)["items"]

            last_date = _items.last ? Time.at(_items.last["date"].to_i).to_datetime : nil
            break if last_date.blank? || last_date < date
          end if !last_date.blank? && last_date > date

          return _items.select { |item| Time.at(item["date"].to_i).to_datetime > date }
        end
        
        _items
      end

      # Get last posts by N days from user_timeline
      #
      def last_post_by_days(days, options = {})
        options = { :days => days }.merge(options)

        last_posts(options)
      end      

      # Get object likes (post, comment, photo, audio, video, note, photo_comment, video_comment, topic_comment, sitepage)
      #
      def object_likes(uid, options = {})
        params = { 
          :owner_id => user.identifier,
          :count => 1000, 
          :type => "post", 
          :item_id => uid,
          :offset => 0
        }

        params.merge!(options)

        user.likes.getList(params)  
      end

      # Get post comments
      #
      def post_comments(uid, options = {})
        params = { 
          :owner_id => user.identifier,
          :count => 100, 
          :preview_length => 0, 
          :need_likes => 1,
          :post_id => uid,
          :offset => 0
        }

        params.merge!(options)

        user.wall.getComments(params)  
      end

      # Get all photos comments
      #
      def photos_comments(options = {})
        params = { 
          :owner_id => user.identifier,
          :count => 100, 
          :need_likes => 1,
          :offset => 0
        }

        params.merge!(options)

        user.photos.getAllComments(params)  
      end

      # Get all friends list
      #
      def friends(options={})
        options = {
          :count => 5000,
          :offset => 0,
          :fields => "domain"
        }.merge(options)

        fetch_all_method_items(:fetch_friends, options)
      end

      # Get all followers list
      #
      def followers(options={})
        options = {
          :count => 1000,
          :offset => 0,
          :fields => "screen_name"
        }.merge(options)

        fetch_all_method_items(:fetch_followers, options)
      end
      
      protected
      
        def user
          @user ||= ::Vkontakte::App::User.new(uid, :access_token => access_token)
        end

        def fetch_all_method_items(name, options)
          response = user.send(name, options)

          _items = response["items"]
          iteration = (response["count"].to_i / _items.size.to_f).ceil

          iteration.times do |index|
            next if index == 0

            options[:offset] += options[:count]
            _items += user.send(name, options)["items"]
          end

          _items
        end
    end

    class Album
      
      def initialize(response, target)
        @hash = normalize_hash(response)
        @target = target
      end
      
      def http_client
        @http_client ||= ::HTTPClient.new(:agent_name => 'SocialProfile robot/0.1')
      end
      
      # Get album id
      def identifier
        @hash['aid']
      end
      
      # Upload photo to album
      #
      # album.photo!(
      #   :source => File.new('/path/to/image')
      #   :message => "some photo info"
      # )
      #
      # http://vk.com/developers.php?oid=-1&p=%D0%9F%D1%80%D0%BE%D1%86%D0%B5%D1%81%D1%81_%D0%B7%D0%B0%D0%B3%D1%80%D1%83%D0%B7%D0%BA%D0%B8_%D1%84%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2_%D0%BD%D0%B0_%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80_%D0%92%D0%9A%D0%BE%D0%BD%D1%82%D0%B0%D0%BA%D1%82%D0%B5
      # 
      def photo!(options)
        return if identifier.nil?
        
        if upload_url = find_upload_url
          data = http_client.post(upload_url, 'file1' => options[:source])
          parsed_response = MultiJson.decode(data.body)
          
          @target.photos.save(parsed_response.merge('caption' => options[:message]))
        end
      end
      
      def respond_to?(method_name)
        @hash.has_key?(method_name.to_s) ? true : super
      end
      
      def method_missing(method_name, *args, &block)
        if @hash.has_key?(method_name.to_s)
          @hash[method_name.to_s]
        else
          super
        end
      end

      protected

        def find_upload_url
          server = @target.photos.getUploadServer(:aid => identifier)

          if server && server['upload_url']
            server['upload_url']
          elsif server && server['response']
            server['response']['upload_url']
          else
            nil
          end
        end

        def normalize_hash(hash)
          hash = hash["response"] if hash.is_a?(Hash) && hash["response"]
          response = Array.wrap(hash).first
          response || {}
        end
    end

  end
end