require "selenium-webdriver"

require_relative "automaton/page"
require_relative "automaton/tab"

class Automaton
  def larvae_update_available?
    !!@driver.find_element(:tag_name, "tabs").find_elements(:class, "tab-resource")[1].find_element(:class, "glyphicon-circle-arrow-up") rescue false
  end

  def territory_tab_present?
    !!@driver.find_element(:tag_name, "tabs").find_elements(:class, "tab-resource")[2] rescue false
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