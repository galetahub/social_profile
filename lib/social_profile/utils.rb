# encoding: utf-8
require "uri"
require "net/http"
require "ostruct"

module SocialProfile
  class Utils
    def self.head(url, options = {})
      uri = URI.parse(url)
      response = nil

      Net::HTTP.start(uri.host, uri.port) do |http|
        http.open_timeout = 2
        http.read_timeout = 2
        response = http.head(uri.request_uri)
      end

      Response.new(uri, response, options)
    end

    def self.blank?(value)
      value.nil? || value.to_s.empty?
    end

    def self.exists?(value)
      !blank?(value)
    end
  end
end