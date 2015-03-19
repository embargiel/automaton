require "selenium-webdriver"
require 'pry'

class Automaton
  class MeatTab
    class Page
      def initialize(driver)
        @driver = driver
      end

      def unit_type
        @driver.find_element(:tag_name, :h3).text
      end
    end

    def initialize(driver)
      @driver = driver
      while !loaded?
      end
      @pages_table = @driver.find_element(:class, 'unit-table')
      @pages_count = @pages_table.find_elements(:class, "ng-scope").length
    end

    def each_page
      @pages_count.times do |i|
        link = @driver.find_element(:class, 'unit-table').find_elements(:class, "ng-scope")[i].find_element(:class, "titlecase")
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

  def initialize
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to "https://swarmsim.github.io"
  end

  def meat_tab
    @driver.navigate.to 'https://swarmsim.github.io/#/tab/meat'
    MeatTab.new(@driver)
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
automaton.reset!

meat_tab = automaton.meat_tab
meat_tab.each_page do |page|
  puts page.unit_type

end
# meat_tab.each_page do |page|
#   if page.unit_count == 0
#     if page.unit_type == "Drone"
#       page.buy(1)
#     end
#   end
# end

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