module EventMachine
  module Sofa
    autoload :Version, 'em-sofa/version'
    autoload :Mapping, 'em-sofa/mapping'
    autoload :TVRage,  'em-sofa/tvrage'
    require File.join(File.dirname(__FILE__), 'em-sofa', 'request')
  end
end
