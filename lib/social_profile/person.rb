require "social_profile/version"

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

      klass = case provider.to_s
        when "facebook" then People::Facebook
        when "vkontakte" then People::Vkontakte
        when "twitter" then People::Twitter
        when "instagram" then People::Instagram
        else Person
      end
    
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
  end
end