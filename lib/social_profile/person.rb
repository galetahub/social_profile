require "social_profile/version"
require 'multi_json'
require 'active_support'
require 'active_support/core_ext'

module SocialProfile
  class Person
    attr_reader :uid, :access_token, :options

    def initialize(uid, access_token, options = {})
      @uid = uid
      @access_token = access_token
      @options = options
    end

    def self.get(provider, uid, access_token, options = {})
      return if provider.nil?

      klass_str = "SocialProfile::People::#{classify(provider)}"
      klass = const_defined?(klass_str) ? const_get(klass_str) : Person

      klass.new(uid, access_token, options)
    end

    # Find album by id
    def fetch_album(album_id)
      raise NotImplementedError("Subclasses should implement this!")
    end

    # Create new album id
    def album!(options = {})
      raise NotImplementedError("Subclasses should implement this!")
    end

    def find_album(album_id)
      return if album_id.nil?

      begin
        fetch_album(album_id)
      rescue Exception => e
        return nil
      end
    end

    def find_or_create_album(album_id, options = {})
      record = find_album(album_id)
      record ||= album!(options)
      record
    end

    def share_photo!(album_id, filepath, options = {})
      album = find_or_create_album(album_id, options[:album])

      data = {
        :source => File.new(filepath)
      }.merge(options[:photo] || {})

      album.photo!(data)
    end

    def tag_object!(object, tags)
      tags = Array.wrap(tags)

      return if tags.empty? || object.nil?

      object.tag!(:tags => tags)
    end

    # Get friends count
    def friends_count(options = {})
      nil
    end

    # Get followers count
    def followers_count(options = {})
      nil
    end

    private

    def self.classify(klass_str)
      klass_str.to_s.split('_').map(&:capitalize).join
    end

    def classify(klass_str)
      self.classify(klass_str)
    end
  end
end
