require "selenium-webdriver"

require_relative "automaton/page"
require_relative "automaton/tab"
require_relative "automaton/config"

class Automaton
  def self.config
    @config ||= Config.new
  end

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
    !!@driver.find_element(:css, "tabs .tab-resource:nth-child(2) .glyphicon-circle-arrow-up") rescue false
  end

  def territory_tab_present?
    !!@driver.find_element(:css, "tabs .tab-resource:nth-child(3)") rescue false
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

  def load!
    @driver.navigate.to 'https://swarmsim.github.io/#/options'
    save = File.open('save').read
    input = @driver.find_element(:id, "export")
    input.clear
    @driver.execute_script("document.getElementById('export').value = '#{save}'")
    input.send_key(:space)
    # binding.pry
    # binding.pry
    # @driver.execute_script("document.getElementById('export').setAttribute('value', #{save})")
    # save.split.each do |char|
    #   input.send_key(char)
    # end
  end

  def save_progress!
    @driver.navigate.to 'https://swarmsim.github.io/#/options'
    save = @driver.find_element(:id, "export").attribute("value")
    File.open('save', 'w') do |file|
      file.write(save)
    end
  end
end