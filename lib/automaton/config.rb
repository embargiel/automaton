class Automaton
  class Logger
    def log_unit(type, count)
      puts "There is #{count} of #{type}"
    end
  end

  class Config
    attr_reader :logger

    def initialize
      @logger = Logger.new
    end
  end
end