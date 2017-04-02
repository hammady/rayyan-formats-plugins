# coding: utf-8

# developemnt instructions:
# 1- Do your modifications
# 2- Increase version number in lib/rayyan-formats-plugins/version.rb
# 3- gem build rayyan-formats-plugins.gemspec
# 4a- test the code by pointing Gemfile entry to rayyan-formats-plugins path
# 4b- test by: gem install rayyan-formats-plugins-VERSION.gem then upgrade version in Gemfile
# 5- git add, commit and push
# 6- gem push rayyan-formats-plugins-VERSION.gem


lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rayyan-formats-plugins/version'

Gem::Specification.new do |spec|
  spec.name          = "rayyan-formats-plugins"
  spec.version       = RayyanFormats::Plugins::VERSION
  spec.authors       = ["Hossam Hammady"]
  spec.email         = ["github@hammady.net"]
  spec.description   = %q{Rayyan plugins for import/export of reference file formats. More formats can be supported and enabled via the initializer. }
  spec.summary       = %q{Rayyan plugins for import/export of reference file formats}
  spec.homepage      = "https://github.com/rayyan/rayyan-formats-plugins"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency 'rake', '~> 0'

  spec.add_dependency 'rayyan-formats-core', "~> 0.0.1"
  spec.add_dependency 'bibtex-ruby', "~> 4.4"
  spec.add_dependency 'ref_parsers', "~> 0.0.1"
end
