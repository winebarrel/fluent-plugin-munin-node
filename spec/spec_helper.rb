$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fluent/test'
require 'fluent/plugin/in_munin_node'
require 'time'
require 'timecop'

# Disable Test::Unit
module Test::Unit::RunCount; def run(*); end; end
Test::Unit.run = true if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)

NODE_HOST = '127.0.0.1'
NODE_PORT = 4949

RSpec.configure do |config|
  config.before(:all) do
    Fluent::Test.setup
    Timecop.freeze(Time.parse('2015/05/24 18:30 UTC'))
  end
end

def create_driver(options = {})
  additional_options = options.select {|k, v| v }.map {|key, value|
    "#{key} #{value}"
  }.join("\n")

  fluentd_conf = <<-EOS
type munin_node
#{additional_options}
  EOS

  Fluent::Test::OutputTestDriver.new(Fluent::MuninNodeInput, 'test.default').configure(fluentd_conf)
end

### servers ###
require File.expand_path('../servers', __FILE__)
start_munin_node
