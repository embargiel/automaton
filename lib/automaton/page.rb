class Automaton
  class Page
    def initialize(driver)
      @driver = driver
      # @buyupgrade =
    end

    def buy_spawn_upgrade!
      @driver.find_elements(:tag_name, "buyupgrade")[1].find_elements(:tag_name, "a").last.click
    end

    def spawn_upgrade_visible?
      !!@driver.find_elements(:tag_name, "buyupgrade")[1] rescue false
    end

    def buy_production_upgrade!
      @driver.find_element(:tag_name, "buyupgrade").find_element(:tag_name, "a").click
    end

    def production_upgrade_visible?
      !!@driver.find_element(:tag_name, "buyupgrade") rescue false
    end

    def production_upgrade_cost
      @driver.find_elements(:tag_name, "cost")[1].text.gsub(",", "").to_f
    end

    def unit_type
      @driver.find_element(:tag_name, :h3).text
    end

    def unit_count
      @unit_count ||= @driver.find_element(:tag_name, "unit").find_element(:tag_name, "ng-pluralize").text.split[2].gsub(",", "").to_f
    end

    def available_count
      @driver.find_element(:tag_name, "buyunit").find_elements(:tag_name, "a").last.text.split.last.gsub(",", "").to_f
    end

    def buy_quarter
      if @driver.find_element(:tag_name, "buyunit").find_elements(:tag_name, "a").length == 3
        @driver.find_element(:tag_name, "buyunit").find_elements(:tag_name, "a")[1].click
      end
    end

    def twins
      t = @driver.find_element(:tag_name, "unit").find_element(:class, "form-group").text
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
      @driver.find_element(:tag_name, "buyunit").find_elements(:tag_name, "a").first.click
    end
  end
end