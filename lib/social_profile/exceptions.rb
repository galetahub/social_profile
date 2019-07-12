module SocialProfile
  class AuthorizationError < StandardError
    def initialize(klass)
      @klass = klass
    end

    def message
      "#{@klass} not authorized!"
    end
  end
end
