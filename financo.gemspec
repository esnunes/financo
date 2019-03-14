# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'financo/version'

Gem::Specification.new do |spec|
  spec.name = 'financo'
  spec.version = Financo::VERSION
  spec.authors = ['Eduardo Nunes']
  spec.email = ['esnunes@gmail.com']

  spec.summary = ''
  spec.homepage = 'https://github.com/esnunes/financo'
  spec.license = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
