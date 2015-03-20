require "selenium-webdriver"

require_relative "automaton/page"
require_relative "automaton/tab"

class Automaton
  def initialize
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to "https://swarmsim.github.io"
  end

  def meat_tab
    @driver.navigate.to 'https://swarmsim.github.io/#/tab/meat'
    Tab.new(@driver)
  end

  def territory_tab
    @driver.navigate.to 'https://swarmsim.github.io/#/tab/territory'
    Tab.new(@driver)
  end

  def larvae_page
    @driver.navigate.to "https://swarmsim.github.io/#/tab/larva/unit/larva"
    Page.new(@driver)
  end

  def ensure_scientific_format!
    @driver.navigate.to 'https://swarmsim.github.io/#/options'

    elem = @driver.find_element(:tag_name, :input) rescue nil

    while elem.nil?
      elem = @driver.find_element(:tag_name, :input) rescue nil
    end

    @driver.find_elements(:tag_name, :input).each do |input|
      if input.attribute("value") == 'scientific-e'
        input.click
      end
    end
  end

  def larvae_update_available?
    !!@driver.find_element(:css, "tabs .tab-resource:nth-child(1) .glyphicon-circle-arrow-up") rescue false
  end

  def territory_tab_present?
    !!@driver.find_element(:css, "tabs .tab-resource:nth-child(2)") rescue false
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