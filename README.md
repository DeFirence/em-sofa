# EM-Sofa

A simple fiber-aware EventMachine based Ruby library for the TVRage API (viewable [here](http://services.tvrage.com/index.php?page=public)).
A fork of the origional sofa library by Henry Hsu (available at [http://github.com/hsume2/sofa](http://github.com/hsume2/sofa)).

## Shows

    EventMachine.run do
      EM::Sofa::TVRage::Show.by_name("Chuck") do |show|
        show # => #<EventMachine::Sofa::TVRage::Show:0x101360d38 @name="Chuck", @show_id="15614", ...>
      end.errback do |ex|
        puts "An error occurred while processing the request. Reason: #{ex.message}"
      end
      # OR
      EM::Sofa::TVRage::Show.new("15614") do |show|
        show # => #<EventMachine::Sofa::TVRage::Show:0x101360d38 @name="Chuck", @show_id="15614", ...>
      end.errback do |ex|
        puts "An error occurred while processing the request. Reason: #{ex.message}"
      end

      # OR (using EM-Synchrony)
      EM.synchrony do
        begin
          show = EM::Sofa::TVRage::Show.by_name("Chuck")
          show # => #<EventMachine::Sofa::TVRage::Show:0x7f9f838 @name="Chuck", @show_id="15614", ...>
        rescue EM::Sofa::TVRage::Show::NotFound => ex
          puts "An error occurred while processing the request. Reason: #{ex.message}"
        rescue EM::Sofa::TVRage::HttpError => ex
          puts "A HTTP error occured while processing the request. Reason: #{ex.message}"
        end
      end
    end

#### Eager loading Season and Episode info

    EM::Sofa::TVRage::Show.by_name("Chuck", :greedy => true) do |show|
      show # => #<EventMachine::Sofa::TVRage::Show:0x4f97868 @name="Chuck", @show_id="15614", ...>
    end
    EM::Sofa::TVRage::Show.new("15614", :greedy => true) do |show|
      show # => #<EventMachine::Sofa::TVRage::Show:0x4ea5000 @name="Chuck", @show_id="15614", ...>
    end

#### Attributes

    show.show_id              # => "15614"
    show.name                 # => "Chuck"
    show.show_link            # => "http://tvrage.com/Chuck"
    show.started              # => "2007"
    show.network              # => "NBC"
    show.air_time             # => "20:00"
    show.time_zone            # => "GMT-5 -DST"
    show.run_time             # => "60"
    show.origin_country       # => "US"
    show.air_day              # => "Monday"
    show.ended                # => nil
    show.classification       # => "Scripted"
    show.seasons              # => "3"
    show.start_date           # => "Sep/24/2007"
    show.status               # => "Returning Series"
    show.genres               # => ["Action", "Comedy", "Drama"]
    show.akas                 # => "Chuck"
    show.latest_episode       # => { :date => #<Date>, :name => "Chuck Versus the Ring: Part 2", :number => "03x19" }
    show.next_episode         # => { :date => #<Date>, :name => "Chuck Versus the Anniversary", :number=>"04x01" }

## Seasons

    show.season_list do |season_list|
      season_list             # => [#<EventMachine::Sofa::TVRage::Season:0x1022d0f98 @no="1", @episodes=[...]>,
                                    #<EventMachine::Sofa::TVRage::Season:0x1022c88c0 @no="2", @episodes=[...]>,
                                    ...]
      season_list.first       # => #<EventMachine::Sofa::TVRage::Season:0x1022d0f98 @no="1", @episodes=[...]>
    end

    # OR (using EM-Synchrony)
    EM.synchrony do
      show.season_list.first  # => #<EventMachine::Sofa::TVRage::Season:0x1022d0f98 @no="1", @episodes=[...]>
    end

#### Attributes

    season.episodes           # => [#<EventMachine::Sofa::TVRage::Episode:0x1022d07a0 @title="Pilot", ...>,
                                    #<EventMachine::Sofa::TVRage::Episode:0x1022cf148 @title="Chuck Versus the Helicopter", ...>,
                                    ...]
    season.no                 # => "1"

## Episodes

    show.episode_list do |episode_list|
      episode_list            # => [#<EventMachine::Sofa::TVRage::Episode:0x1022d07a0 @title="Pilot", ...>,
                                    #<EventMachine::Sofa::TVRage::Episode:0x1022cf148 @title="Chuck Versus the Helicopter", ...>,
                                    ...]
      show.episode_list.first # => #<EventMachine::Sofa::TVRage::Episode:0x1022d07a0 @title="Pilot", ...>
    end

#### Attributes

    episode.title             # => "Pilot"
    episode.air_date          # => "2007-09-24"
    episode.num_in_season     # => "01"
    episode.num               # => "1"
    episode.prod_num          # => "101"
    episode.link              # => "http://www.tvrage.com/Chuck/episodes/579282"

## Contributing
 
* Feel free to send feature/pull requests.

## Copyright

Copyright (c) 2010 DeFirence. See LICENSE for details.
