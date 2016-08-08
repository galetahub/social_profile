require "rspec"
require "social_profile"
require 'webmock/rspec'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # WebMock.allow_net_connect!

  # == Mock Framework
  config.mock_with :rspec

  config.after(:all) do
  end
end

def fixture(file)
  File.read(SocialProfile.root_path.join('spec/mock_json', file))
end
