require 'faraday'
require 'cgi'

module SocialProfile
  class HTTPParser
    def initialize(url, cookies_path)
      @url = url
      @cookies_path = cookies_path
    end

    private

    def cookies
      @cookies ||= File.read(@cookies_path)
    end

    def client
      @client ||= Faraday.new(@url) do |request|
        request.request :url_encoded
        request.adapter Faraday.default_adapter
        request.headers['Cookie'] = cookies
      end
    end
  end
end
