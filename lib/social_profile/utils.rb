# encoding: utf-8
require "uri"
require "net/http"

module SocialProfile
  class Utils
    def self.head(url, options = {})
      uri = URI.parse(url)
      response = nil

      Net::HTTP.start("#{uri.scheme}://#{uri.host}", 80) do |http|
        http.open_timeout = 2
        http.read_timeout = 2
        response = http.head(uri.path)
      end

      response
    end
  end
end