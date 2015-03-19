require "selenium-webdriver"
require 'pry'

class Automaton
  def initialize
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to "https://swarmsim.github.io"
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
automaton.close!
