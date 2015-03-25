begin
  require "pry"

  require_relative "lib/automaton"

  if ENV['profile']
    require "ruby-prof"
    begin_time = Time.now
    RubyProf.start

    condition_proc = Proc.new { Time.now - begin_time < 100 }
  else
    condition_proc = Proc.new { true }
  end

  automaton = Automaton.new
  automaton.ensure_scientific_format!
  automaton.reset! if ENV['reset']
  automaton.load!

  # binding.pry

  @calculuus = {}

  while(condition_proc.call)
    meat_tab = automaton.meat_tab
    meat_tab.each_page do |page|
      @calculuus[page.unit_type] = page.unit_count

      #log number
      # Automaton.config.logger.log_unit(page.unit_type, page.unit_count)

      #buy upgrades
      if page.production_upgrade_visible?
        if page.unit_count >= page.production_upgrade_cost * 2
          page.buy_production_upgrade!
        end
      end
      if page.spawn_upgrade_visible?
        # TODO: Figure out a good metric to decide when we should buy spawn updates
        page.buy_spawn_upgrade!
      end

      #buy units

      if page.unit_count == 0
        if page.unit_type == "Drone"
          page.buy(3)
        else
          if page.available_count > 0
            page.buy(1)
          end
        end
      elsif page.unit_count > 0
        if page.unit_type == "Drone" and @calculuus["Queen"].to_i == 0
          page.buy_max
        else
          closest_power_of_10 = 10 ** Math.log10(page.unit_count).ceil
          difference = closest_power_of_10 - page.unit_count
          if difference < page.unit_count
            if difference < page.available_count
              page.buy(difference)
            end
          elsif page.available_count >= page.unit_count
            page.buy_max
          end
        end
      end
    end

    if automaton.larvae_update_available?
      larvae_page = automaton.larvae_page
      larvae_page.buy_all_upgrades!
    end

    if automaton.territory_tab_present?
      territory_tab = automaton.territory_tab
      territory_tab.reverse_each_page do |page|
        if page.production_upgrade_visible?
          page.buy_all_upgrades!
        end
        if page.unit_count < 1.0e15
          page.buy_quarter
        end
      end
    end

    automaton.save_progress!
  end


  if ENV['profile']
    result = RubyProf.stop

    printer = RubyProf::GraphHtmlPrinter.new(result)

    Pathname.new(FileUtils.pwd).join("benchmark.html").open("w+") do |file|
      printer.print(file, {})
    end
  end
ensure
  automaton.save_progress!
  automaton.close!
end