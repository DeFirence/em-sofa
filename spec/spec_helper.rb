$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
#require 'eventmachine'
require 'bacon'
require 'em-spec/bacon'
require 'em-sofa'
#require 'mocha'

EM.spec_backend = EventMachine::Spec::Bacon
#require 'spec'
#require 'spec/autorun'

require 'fakeweb'

FakeWeb.allow_net_connect = false

#Spec::Runner.configure do |config|
#  config.mock_with :mocha
#end
