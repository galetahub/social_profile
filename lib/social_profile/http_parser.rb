require 'faraday'
require 'cgi'

module SocialProfile
  class HTTPParser
    def initialize(url, cookies_path = nil, options = {})
      @url = url
      @cookies_path = cookies_path
      @options = options
    end

    def client
      return @options[:client] if @options[:client]

      options = { ssl: { verify: false }, request: { timeout: 10 } }
      @client ||= Faraday.new(@url, options) do |request|
        request.request :url_encoded
        request.adapter Faraday.default_adapter
        request.headers['Cookie'] = cookies if @cookies_path
        request.headers['Authorization'] = "Bearer #{@options[:access_token]}" if @options[:access_token]
        request.proxy @options[:proxy] if @options[:proxy]
      end
    end

    private

    def cookies
      if @cookies_path
        return @cookies ||= @cookies_path unless File.exists?(@cookies_path)

        @cookies ||= File.read(@cookies_path)
      end
    end
  end
end
