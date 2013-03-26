module SocialProfile
  class Response
    attr_reader :uri, :response, :body, :headers

    def initialize(uri, response, options={})
      @uri          = uri
      @response     = response
      @body         = response.body || options[:body]
      @headers      = response.to_hash
    end

    def code
      response.code.to_i
    end

    def respond_to?(name)
      return true if [:uri, :response, :body, :headers].include?(name)
      response.respond_to?(name)
    end

    protected

      def method_missing(name, *args, &block)
        if response.respond_to?(name)
          response.send(name, *args, &block)
        else
          super
        end
      end
  end
end