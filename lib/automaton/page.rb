class Automaton
  class Page
    def initialize(driver)
      @driver = driver
      while !loaded?
      end
    end

    def buy_spawn_upgrade!
      @driver.find_element(:css, "buyupgrade:nth-child(2) a").click
    end

    def spawn_upgrade_visible?
      !!@driver.find_element(:css, "buyupgrade:nth-child(2)") rescue false
    end

    def buy_production_upgrade!
      @driver.find_element(:css, "buyupgrade a").click
    end

    def production_upgrade_visible?
      !!@driver.find_element(:tag_name, "buyupgrade") rescue false
    end

    def production_upgrade_cost
      @driver.find_element(:css, "cost:nth-child(2)").text.gsub(",", "").to_f
    end

    def unit_type
      @driver.find_element(:tag_name, :h3).text
    end

    def unit_count
      @unit_count ||= @driver.find_element(:css, "unit ng-pluralize:first-child").text.split[2].gsub(",", "").to_f
    end

    def available_count
      @driver.find_element(:css, "buyunit a:last-child").text.split.last.gsub(",", "").to_f
    end

    def buy_quarter
      if @driver.find_elements(:css, "buyunit a").length == 3
        @driver.find_element(:css, "buyunit a:nth-child(2)").click
      end
    end

    def twins
      t = @driver.find_element(:css, "unit .form-group").text
      v = t.scan(/\(×\d+/).first
      if v.nil?
        1
      else
        v['(×'] = ""
        v.to_i
      end
    end

    def buy_all_upgrades!
      upgrades_count = @driver.find_elements(:tag_name, "buyupgrade").length

      upgrades_count.times do |i|
        @driver.find_elements(:tag_name, "buyupgrade")[i].find_elements(:tag_name, "a").last.click
      end
    end

    def buy(count)
      input = @driver.find_element(:tag_name, "input")
      while input.attribute("value").length > 0
        input.send_key :backspace
      end
      actual_buy_value = ((count.to_f / twins) + 1).to_i
      input.send_keys(actual_buy_value)
      @driver.find_element(:css, "buyunit a:first-child").click
    end

    private

    def loaded?
      !!@driver.find_element(:css, "unit ng-pluralize:first-child") rescue false
    end
  end
end