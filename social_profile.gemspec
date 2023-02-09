# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'social_profile/version'

Gem::Specification.new do |spec|
  spec.name          = 'social_profile'
  spec.version       = SocialProfile::VERSION
  spec.authors       = ['Igor Haleta', 'Pavlo Haleta']
  spec.email         = ['galeta.igor@gmail.com']
  spec.description   = %q{Wrapper for Omniauth profile hash, post photo to album}
  spec.summary       = %q{Wrapper for Omniauth profile hash}
  spec.homepage      = 'https://github.com/galetahub/social_profile'
  spec.license       = 'MIT'

  spec.required_ruby_version = '~> 2.3'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'capybara'
  spec.add_dependency 'fb_graph2', '~> 0.9.1'
  spec.add_dependency 'google-api-client', '~> 0.9.28'
  spec.add_dependency 'httpclient'
  # spec.add_dependency 'instagram', '~> 1.1.6'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'twitter', '~> 6.2.0'
  spec.add_dependency 'vkontakte', '~> 0.0.6'

  spec.add_dependency 'selenium-webdriver', '~> 3.142.1'
end
