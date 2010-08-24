module EventMachine
  module Sofa
    module TVRage
      # This class will hold the full/quick schedule information as per the TVRage API.
      #
      # @see http://services.tvrage.com/index.php?page=public&go=fullschedule TVRage API : Full Schedule
      # @see http://services.tvrage.com/index.php?page=public&go=quickschedule TV Rage API : Quick Schedule
      class Schedule
        Base_Uri = 'services.tvrage.com/feeds'

        extend TVRage

        class << self
          # Gets the full schedule for country
          #
          # @param country [String] The country to query in (US, UK, NL)
          # @param &block [Block] Called back with result unless fibered
          # @return [Hash] The parsed XML of schedule information
          # @see http://services.tvrage.com/feeds/fullschedule.php?country=US US's Full Schedule
          def full(country, &block)
            return Request.fibered(method(__method__), country) if defined? Fiber and Fiber.respond_to? :current and not block
            Request.new(Base_Uri, '/fullschedule.php', block, :return_element => 'schedule', :country => country)
          end
        end
      end
    end
  end
end