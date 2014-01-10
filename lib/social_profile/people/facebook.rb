require "fb_graph"

module SocialProfile
  module People
    class Facebook < Person
      FRIENDS_FQL = "SELECT friend_count FROM user WHERE uid=me()"

      # Find album by id
      def fetch_album(album_id)
        ::FbGraph::Album.fetch(album_id, :access_token => access_token)
      end
      
      # Create new album id
      def album!(options = {})
        user.album!(options)
      end

      # Get friends count
      def friends_count
        @friends_count ||= fetch_friends_count
      end

      def fetch_friends_count
        response = FbGraph::Query.new(FRIENDS_FQL).fetch(:access_token => access_token)

        response = response.first if response.is_a?(Array)
        return nil if response.is_a?(Hash) && response["friend_count"].blank?

        response["friend_count"].to_i
      end
      
      protected
      
        def user
          @user ||= ::FbGraph::User.me(access_token)
        end
    end
  end
end