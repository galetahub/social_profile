require 'faraday'
require 'cgi'

module SocialProfile
  class HTTPParser
    def initialize(url, cookies_path, options = {})
      @url = url
      @cookies_path = cookies_path
      @options = options
    end

    def client
      options = { ssl: { verify: false }, request: { timeout: 10 } }
      @client ||= Faraday.new(@url, options) do |request|
        request.request :url_encoded
        request.adapter Faraday.default_adapter
        request.headers['Cookie'] = cookies
        request.proxy @options[:proxy] if @options[:proxy]
      end
    end

    private

    def cookies
      @cookies ||= File.read(@cookies_path)
    end
  end
end
