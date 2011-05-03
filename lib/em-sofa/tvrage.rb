#require 'em-http-request'
require 'crack'

module EventMachine::Sofa
  module TVRage
    autoload :Schedule, 'em-sofa/tvrage/schedule'
    autoload :Show, 'em-sofa/tvrage/show'
    autoload :Season, 'em-sofa/tvrage/season'
    autoload :Episode, 'em-sofa/tvrage/episode'

    class HttpError < RuntimeError
    end
  end
end
