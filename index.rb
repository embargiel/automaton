require "selenium-webdriver"
require 'pry'

class Automaton
  class MeatTab
    class Page
      def initialize(driver)
        @driver = driver
      end

      def buy_upgrades!
        if production_upgrade_visible?
          if unit_count * 2 >= production_upgrade_cost
            buy_production_upgrade!
          end
        end
        if spawn_upgrade_visible?
          # TODO: Figure out a good metric to decide when we should buy spawn updates
          buy_spawn_upgrade!
        end
      end

      def buy_spawn_upgrade!
        @driver.find_elements(:tag_name, "buyupgrade")[1].find_elements(:tag_name, "a").last.click
      end

      def spawn_upgrade_visible?
        !!@driver.find_elements(:tag_name, "buyupgrade")[1] rescue false
      end

      def buy_production_upgrade!
        @driver.find_elements(:tag_name, "buyupgrade").first.find_element(:tag_name, "a").click
      end

      def production_upgrade_visible?
        !!@driver.find_element(:tag_name, "buyupgrade") rescue false
      end

      def production_upgrade_cost
        @driver.find_elements(:tag_name, "cost")[1].text.gsub(",", "").to_f
      end

      def buy_units!
        if unit_count == 0
          if unit_type == "Drone"
            buy(3)
          else
            if available_count > 0
              buy(1)
            end
          end
        elsif unit_count > 0
          if available_count >= unit_count
            buy(unit_count)
          end
        end
      end

      def unit_type
        @driver.find_element(:tag_name, :h3).text
      end

      def unit_count
        @driver.find_element(:tag_name, "unit").find_element(:tag_name, "ng-pluralize").text.split[2].gsub(",", "").to_f
      end

      def available_count
        @driver.find_element(:tag_name, "buyunit").find_elements(:tag_name, "a").last.text.split.last.gsub(",", "").to_f
      end

      def buy(count)
        input = @driver.find_element(:tag_name, "input")
        while input.attribute("value").length > 0
          input.send_key :backspace
        end
        input.send_keys(count)
        @driver.find_element(:tag_name, "buyunit").find_elements(:tag_name, "a").first.click
      end
    end

    def initialize(driver)
      @driver = driver
      while !loaded?
      end
      @pages_table = @driver.find_element(:class, 'unit-table')
      # -1 because we don't care about the meat tab
      @pages_count = @pages_table.find_elements(:tag_name, "tr").length - 1
    end

    def each_page
      @pages_count.times do |i|
        scope = @driver.find_element(:class, 'unit-table').find_elements(:tag_name, "tr")[i]
        link  = scope.find_element(:class, "titlecase") rescue binding.pry
        link.click
        page = Page.new(@driver)
        yield(page)
      end
    end

    private

    def loaded?
      !!@driver.find_element(:class, 'unit-table') rescue false
    end
  end

  class LarvaPage
    def initialize(driver)
      @driver = driver
    end

    def buy_all_upgrades!
      upgrades_count = @driver.find_elements(:tag_name, "buyupgrade").length

      upgrades_count.times do |i|
        @driver.find_elements(:tag_name, "buyupgrade")[i].find_elements(:tag_name, "a").first.click
      end
    end
  end

  def initialize
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to "https://swarmsim.github.io"
  end

  def meat_tab
    @driver.navigate.to 'https://swarmsim.github.io/#/tab/meat'
    MeatTab.new(@driver)
  end

  def larvae_page
    @driver.navigate.to "https://swarmsim.github.io/#/tab/larva/unit/larva"
    LarvaPage.new(@driver)
  end

  def larvae_update_available?
    !!@driver.find_element(:tag_name, "tabs").find_elements(:class, "tab-resource")[1].find_element(:class, "glyphicon-circle-arrow-up") rescue false
  end

  def reset!
    @driver.navigate.to 'https://swarmsim.github.io/#/options'

    button = @driver.find_element(:class, 'resetalert') rescue nil
    while button.nil?
      button = @driver.find_element(:class, 'resetalert') rescue nil
    end
    button.click
    @driver.switch_to.alert.accept
  end

  def close!
    @driver.quit
  end
end

automaton = Automaton.new
# automaton.reset!

loop do
  meat_tab = automaton.meat_tab
  meat_tab.each_page do |page|
    page.buy_upgrades!
    page.buy_units!
  end

  if automaton.larvae_update_available?
    larvae_page = automaton.larvae_page
    larvae_page.buy_all_upgrades!
  end
end

automaton.close!


# [8] pry(#<Automaton::MeatTab>)> element = table.find_elements(:class, "ng-scope")
# => [#<Selenium::WebDriver::Element:0x7739488a39f1daea id="{8c11828b-ca36-402e-aab8-3b99b77c509f}">, #<Selenium::WebDriver::Element:0x..fc375f3bc015a399c id="{f85f2f6c-4615-4919-8aa8-8659c2fe33f8}">]
# [9] pry(#<Automaton::MeatTab>)> element.first
# => #<Selenium::WebDriver::Element:0x7739488a39f1daea id="{8c11828b-ca36-402e-aab8-3b99b77c509f}">
# [10] pry(#<Automaton::MeatTab>)> element.first.click
# => "ok"
# [11] pry(#<Automaton::MeatTab>)> element.first.click
# => "ok"
# [12] pry(#<Automaton::MeatTab>)> element.first.find_element("name", "a")
# Selenium::WebDriver::Error::NoSuchElementError: Unable to locate element: {"method":"name","selector":"a"}
# from [remote server] file:///tmp/webdriver-profile20150319-25435-1elsgil/extensions/fxdriver@googlecode.com/components/driver-component.js:10271:in `FirefoxDriver.prototype.findElementInternal_'
# [13] pry(#<Automaton::MeatTab>)> element.first.click
# => "ok"
# [14] pry(#<Automaton::MeatTab>)> element.last.click
# => "ok"
# [15] pry(#<Automaton::MeatTab>)> element.first.find_element(:class, "unit-sidebar")
# Selenium::WebDriver::Error::NoSuchElementError: Unable to locate element: {"method":"class name","selector":"unit-sidebar"}
# from [remote server] file:///tmp/webdriver-profile20150319-25435-1elsgil/extensions/fxdriver@googlecode.com/components/driver-component.js:10271:in `FirefoxDriver.prototype.findElementInternal_'
# [16] pry(#<Automaton::MeatTab>)> element.first
# => #<Selenium::WebDriver::Element:0x7739488a39f1daea id="{8c11828b-ca36-402e-aab8-3b99b77c509f}">
# [17] pry(#<Automaton::MeatTab>)> element.first.children
# NoMethodError: undefined method `children' for #<Selenium::WebDriver::Element:0x0000000231ce30>
# from (pry):17:in `each_page'
# [18] pry(#<Automaton::MeatTab>)> element.first.child
# NoMethodError: undefined method `child' for #<Selenium::WebDriver::Element:0x0000000231ce30>
# from (pry):18:in `each_page'
# [19] pry(#<Automaton::MeatTab>)> element.first.find_element(:class, "titlecase")
# => #<Selenium::WebDriver::Element:0x1b76ba77f3babf26 id="{ab8e9b54-416b-424d-8fa8-0b55428a3d3f}">
# [20] pry(#<Automaton::MeatTab>)> element.first.find_element(:class, "titlecase").click
# => "ok"
# [21] pry(#<Automaton::MeatTab>)>