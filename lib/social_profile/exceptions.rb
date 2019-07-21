module SocialProfile
  class AuthorizationError < StandardError
    def initialize(klass)
      @klass = klass
    end

    def message
      "#{@klass} not authorized!"
    end
  end

  class ProfileInternalError < StandardError
    def message
      'Something went wrong'
    end
  end
end
