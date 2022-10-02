# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitty_policy/version'

Gem::Specification.new do |spec|
  spec.name          = 'kitty_policy'
  spec.version       = KittyPolicy::VERSION
  spec.authors       = ['Radoslav Stankov']
  spec.email         = ['rstankov@gmail.com']

  spec.summary       = 'General purpose authorization library'
  spec.description   = 'Can be used for Rails and GraphQL applications'
  spec.homepage      = 'https://github.com/producthunt/kitty-policy'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/producthunt/kitty-policy'
  spec.metadata['changelog_uri']   = 'https://github.com/producthunt/kitty-policy/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r(^exe/)) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'graphql', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'rspec-mocks', '~> 3.8'
  spec.add_development_dependency 'rubocop', '1.36.0'
  spec.add_development_dependency 'rubocop-rspec', '2.13.2'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
