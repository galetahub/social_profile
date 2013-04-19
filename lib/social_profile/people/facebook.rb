# encoding: utf-8
require "fb_graph"

module SocialProfile
  module People
    class Facebook < Person
      # Find album by id
      def fetch_album(album_id)
        ::FbGraph::Album.fetch(album_id, :access_token => access_token)
      end
      
      # Create new album id
      def album!(options = {})
        user.album!(options)
      end
      
      protected
      
        def user
          @user ||= ::FbGraph::User.me(access_token)
        end
    end
  end
end