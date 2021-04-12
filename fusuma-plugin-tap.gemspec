# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fusuma/plugin/tap/version'

Gem::Specification.new do |spec|
  spec.name          = 'fusuma-plugin-tap'
  spec.version       = Fusuma::Plugin::Tap::VERSION
  spec.authors       = ['iberianpig']
  spec.email         = ['yhkyky@gmail.com']

  spec.summary       = ' Tap gesture plugin for Fusuma '
  spec.description   = ' fusuma-plugin-tap is Fusuma plugin for recognizing multitouch tap. '
  spec.homepage      = 'https://github.com/iberianpig/fusuma-plugin-tap'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3' # https://packages.ubuntu.com/search?keywords=ruby&searchon=names&exact=1&suite=all&section=main

  spec.add_dependency 'fusuma', '~> 2.0.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'github_changelog_generator', '~> 1.14'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
end
