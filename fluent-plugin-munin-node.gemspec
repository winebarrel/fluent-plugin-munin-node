# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent_plugin_munin_node/version'

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-munin-node'
  spec.version       = FluentPluginMuninNode::VERSION
  spec.authors       = ['Genki Sugawara']
  spec.email         = ['sugawara@cookpad.com']

  spec.summary       = %q{Fluentd input plugin for Munin node.}
  spec.description   = %q{Fluentd input plugin for Munin node.}
  spec.homepage      = 'https://github.com/winebarrel/fluent-plugin-munin-node'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'fluentd'
  spec.add_dependency 'munin-ruby', '>= 0.1.4'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'test-unit', '>= 3.1.0'
  spec.add_development_dependency 'timecop'
end
