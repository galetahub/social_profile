module SocialProfile
  module People
    class Linkedin < Person
      def username
        user['vanityName']
      end

      def head_line
        user['localizedHeadline']
      end

      def followers_count
        json = JSON.parse client.get("connections/urn:li:person:#{uid}").body
        json['firstDegreeSize']
      end

      def profile_url
        "https://www.linkedin.com/in/#{username}"
      end

      def user
        @user ||= get_json client.get('me').body
      end

      private

      def client
        @client ||= SocialProfile::HTTPParser.new('https://api.linkedin.com/v2', nil, access_token: access_token).client
      end

      def get_json(json_str)
        JSON.parse json_str
      end
    end
  end
end
