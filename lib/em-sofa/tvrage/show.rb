module EventMachine
  module Sofa
    module TVRage
      class Request
        include EM::Deferrable

        def initialize(block)
          callback {|info| block.call(info) }
        end
      end
      # This class holds the XML information of a single Show as per the TVRage API.
      # It's also the root point for communicating with the API.
      #
      # @see http://services.tvrage.com/index.php?page=public TVRage API
      class Show
        Base_Uri = 'services.tvrage.com'
        Timeout  = 15

        class << self
          # Gets the info for a Show.
          #
          # @param sid [String] The show's id
          # @param &block [Block] Called back with the parsed XML when successful
          # @return [EM:HttpRequest] HTTP request object
          # @see http://services.tvrage.com/feeds/showinfo.php?sid=15614 Chuck's Show Info
          def info(sid, &block)
            raise ArgumentError, "No block given for completion callback" unless block
            request = Request.new(block)
            host = "http://#{Base_Uri}/feeds/showinfo.php"
            http = EM::HttpRequest.new(host).get :query => {:sid => sid}, :timeout => Timeout
            http.callback {
              next request.fail :http_error unless xml = Crack::XML.parse(http.response) rescue nil
              request.succeed xml["Showinfo"]
            }
            http.errback { request.fail http.error }
            request
          end

          # Gets the full show info (info + season list + episode list) for a Show.
          #
          # @param sid [String] The show's id
          # @param &block [Block] Called back with the parsed XML when successful else nil
          # @see http://services.tvrage.com/feeds/full_show_info.php?sid=15614 Chuck's Full Show Info
          def full_info(sid, &block)
            raise ArgumentError, "No block given for completion callback" unless block
            request = Request.new(block)
            host = "http://#{Base_Uri}/feeds/full_show_info.php"
            http = EM::HttpRequest.new(host).get :query => {:sid => sid}, :timeout => Timeout
            http.callback {
              next request.fail :http_error unless xml = Crack::XML.parse(http.response) rescue nil
              request.succeed xml["Show"]
            }
            http.errback { request.fail http.error }
            request
          end

          # Gets the episode list for a Show.
          #
          # @param sid [String] The show's id
          # @param &block [Block] Called back with the parsed XML when successful else nil
          # @see http://services.tvrage.com/feeds/episode_list.php?sid=15614 Chuck's Episode List
          def episode_list(sid, &block)
            raise ArgumentError, "No block given for completion callback" unless block
            request = Request.new(block)
            host = "http://#{Base_Uri}/feeds/episode_list.php"
            http = EM::HttpRequest.new(host).get :query => {:sid => sid}, :timeout => Timeout
            http.callback {
              next request.fail :http_error unless xml = Crack::XML.parse(http.response) rescue nil
              request.succeed xml["Show"]
            }
            http.errback { request.fail http.error }
            request
          end

          # Finds the Show by name using TVRage's Quickinfo API.
          #
          # @param name [String] The name of the show to search for
          # @option options [Boolean] :greedy Whether or not to eager load the Season and Episode info
          # @param &block [Block] Called back with the show with id parsed from the Quickinfo search
          # @see http://services.tvrage.com/index.php?page=public&go=quickinfo TVRage Quickinfo API
          # @see http://services.tvrage.com/tools/quickinfo.php?show=Chuck Chuck's Quickinfo
          def by_name(name, options = {}, &block)
            raise ArgumentError, "No block given for completion callback" unless block
            request = Request.new(block)
            host = "http://#{Base_Uri}/tools/quickinfo.php"
            http = EM::HttpRequest.new(host).get :query => {:show => name}, :timeout => Timeout
            http.callback {
              next request.fail ShowNotFound unless quick_info = Crack::XML.parse(http.response)["pre"] rescue nil
              options[:info] = parsed_quickinfo(quick_info)
              Show.new(options[:info]['showid'], options) {|show| request.succeed show }
            }
            http.errback { request.fail http.error }
            request
          end

          def parsed_quickinfo(raw_info)
            info = Hash[raw_info.split(/\n/).collect {|line| k, v = line.split /@/; [k.gsub(' ', '').downcase, v] }]
            info['showlink'] = info.delete('showurl')
            info.each_key do |key|
              case key.to_sym
                when :latestepisode, :nextepisode
                  info[key] = Hash[[:number, :name, :date].zip(info[key].split /\^/)]
                  info[key][:date] = Date.parse(info[key][:date])
                when :genres
                  info[key] = info[key].split ' | '
              end
            end
          end
        end

        include Mapping

        # @see EM:Sofa::Mapping
        maps(
          :ended          => nil,
          :showid         => :show_id,
          :showname       => :name,
          :name           => nil,
          :showlink       => :show_link,
          :seasons        => nil,
          :started        => nil,
          :startdate      => :start_date,
          :ended          => nil,
          :origin_country => nil,
          :status         => nil,
          :classification => nil,
          :runtime        => :run_time,
          :network        => nil,
          :airtime        => :air_time,
          :airday         => :air_day,
          :timezone       => :time_zone,
          :latestepisode  => :latest_episode,
          :nextepisode    => :next_episode
        )
        maps(:genres => nil) #{ |value| value["genre"] }
        maps(:akas => nil) { |value| value["aka"] }

        # Maps :Episodelist to :season_list
        # @see EM:Sofa::Mapping
        # @yieldparam value [Hash, Array] A Hash of info if there's only one. An Array of info if there's multiple
        # @yieldreturn [Array] A list of seasons initialized with value
        maps(:Episodelist => :season_list) do |value|
          case seasons = value["Season"]
          when Hash
            [Season.new(seasons)]
          when Array
            seasons.map { |info| Season.new(info) }
          end
        end

        # Stores all the info that was greedy-loaded
        #
        # @return [Hash] The full show info (including seasons and episodes)
        # @see Show.full_info
        attr_accessor :greedy

        # Returns a new instance of Show, loading and then mapping info from the TVRage API.
        #
        # @param id [String] The show_id as per the TVRage API
        # @option options [Boolean] :greedy Whether or not to eager load the Season and Episode info
        # @param &block [Block] Called back with the show with parsed info
        def initialize(id, options = {}, &block)
          raise RuntimeError.new("id is required") unless (@show_id = id)
          raise ArgumentError, "No block given for completion callback" unless block
          klass = self.class
          if options[:greedy]
            return block.call(self) if @greedy
            klass.full_info(@show_id) do |full_info|
              next block.call(nil) unless full_info
              update_with_mapping(@greedy = full_info)
              block.call(self)
            end
          elsif options[:info]
            update_with_mapping(options[:info])
            block.call(self)
          else
            klass.info(@show_id) do |info|
              next block.call(nil) unless info
              update_with_mapping(info)
              block.call(self)
            end
          end
        end

        # @param &block [Block] Called back with the list of seasons
        def season_list(&block)
          raise ArgumentError, "No block given for successful callback" unless block
          puts "@season_list = #@season_list" if @season_list
          return block.call(@season_list) if @season_list
          self.class.episode_list(@show_id) do |episode_list|
            update_with_mapping(episode_list)
            block.call(@season_list)
          end
          true
        end

        # @param &block [Block] Called back with the list of episodes
        def episode_list(&block)
          raise ArgumentError, "No block given for successful callback" unless block
          season_list do |seasons|
            block.call(seasons.collect { |season| season.episodes }.flatten)
          end
          true
        end

        class ShowNotFound < RuntimeError
        end
      end
    end
  end
end