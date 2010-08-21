module EventMachine
  module Sofa
    module TVRage
      # This class will hold the full/quick schedule information as per the TVRage API.
      #
      # @see http://services.tvrage.com/index.php?page=public&go=fullschedule TVRage API : Full Schedule
      # @see http://services.tvrage.com/index.php?page=public&go=quickschedule TV Rage API : Quick Schedule
      class Schedule
        Base_Uri = 'services.tvrage.com/feeds'

        class << self
          # Gets the full schedule for country
          #
          # @param country [String] The country to query in (US, UK, NL)
          # @return [Hash] The parsed XML of schedule information
          # @see http://services.tvrage.com/feeds/fullschedule.php?country=US US's Full Schedule
          def full(country, &block)
            host = "http://#{Base_Uri}/fullschedule.php"
            http = EM::HttpRequest.new(host).get :query => {:country => country}, :timeout => Timeout
            http.callback {
              xml = Crack::XML.parse(http.response)
              block.call(xml["schedule"])
            }
            http
          end
        end
      end
    end
  end
end