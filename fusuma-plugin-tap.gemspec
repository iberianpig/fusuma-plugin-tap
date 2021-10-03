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
  spec.files          = Dir['{bin,lib,exe}/**/*', 'LICENSE*', 'README*', '*.gemspec']
  spec.test_files     = Dir['{test,spec,features}/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3' # https://packages.ubuntu.com/search?keywords=ruby&searchon=names&exact=1&suite=all&section=main

  spec.add_dependency 'fusuma', '~> 2.0'
end
