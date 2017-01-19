# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/translation/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-translation'
  spec.version       = Fastlane::Translation::VERSION
  spec.author        = %q{Jakob Jensen}
  spec.email         = %q{jje@trifork.com}

  spec.summary       = %q{Handling translations from Google sheet.}
  spec.homepage      = "https://github.com/trifork/fastlane-plugin-translation"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency 'google-api-client', '0.9.20'
  spec.add_dependency 'google_drive', '2.1.1'
  spec.add_dependency 'nokogiri', '1.5.3'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 2.9.0'
end
