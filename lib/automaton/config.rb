require 'httparty'

class Automaton
  class Logger
    def log_unit(type, count)
      puts "There is #{count} of #{type}"

      send_event(type, count)
    end

    private

    def send_event(type, count)
      params = {
        event_type: "counting_units",
        unit_type: type,
        unit_count: count
      }

      # t.string :event_type
      # t.string :unit_type
      # t.string :unit_count


      HTTParty.post "http://localhost:3000/events",
        body: params.to_json,
        headers: {
          'Content-Type' => 'application/json'
        }
    end
  end

  class Config
    attr_reader :logger

    def initialize
      @logger = Logger.new
    end
  end
end