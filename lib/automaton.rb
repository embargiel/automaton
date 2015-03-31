require "selenium-webdriver"

require_relative "automaton/page"
require_relative "automaton/tab"
require_relative "automaton/config"

class Automaton
  attr_reader :driver

  def self.config
    @config ||= Config.new
  end

  def initialize
    start!
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

  def larvae_production?  
    @driver.navigate.to "https://swarmsim.github.io/#/tab/larva/unit/larva"
    prod = @driver.find_element(:css, "div.ng-binding span.ng-binding").text.split[0].gsub(",", "").to_f
  end

  def cocoon_page
    @driver.navigate.to 'https://swarmsim.github.io/#/tab/larva/unit/cocoon'
    Page.new(@driver)
  end

  def energy_tab
    @driver.navigate.to "https://swarmsim.github.io/#/tab/energy/unit/energy"
    Tab.new(@driver)
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

  def energy_tab_present?
    !!@driver.find_element(:css, "tabs .tab-resource a div.icon-energy") rescue false
  end

  def can_affor_clone?
    @driver.find_element(:css, "tabs .tab-resource:nth-child(4)").text.gsub(",", "").to_f >= 12000
  end

  def check_nexus?
    @driver.navigate.to 'https://swarmsim.github.io/#/tab/energy'
    level = @driver.find_element(:css, ".tab-content .ng-scope:nth-last-child(2) td:nth-child(3)").text
    name = @driver.find_element(:css, ".tab-content .ng-scope:nth-last-child(2) a.titlecase").text
    level == "5" and name == "Nexus"
  end

  def clone_availability?
    @driver.navigate.to 'https://swarmsim.github.io/#/tab/energy/unit/energy'
    @driver.find_element(:css, "div.ng-scope li:nth-child(5) span a").text.to_f    
  end

  def cocoon_quantity?
    @driver.navigate.to 'https://swarmsim.github.io/#/tab/larva/unit/cocoon'
    @driver.find_element(:css, "unit ng-pluralize:first-child").text.split[2].gsub(",", "").to_f
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

  def start!
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to "https://swarmsim.github.io"
    @started_at = Time.now
  end

  def needs_restart?
    (Time.now - @started_at) > 20 * 60 # restart if running for 20 minutes already
  end

  def reset_driver!
    close!
    start!
  end

  def load!
    if File.exists?('save')
      @driver.navigate.to 'https://swarmsim.github.io/#/options'
      save = File.open('save').read
      input = @driver.find_element(:id, "export")
      input.clear
      @driver.execute_script("document.getElementById('export').value = '#{save}'")
      input.send_key(:space)
    end
  end

  def save_progress!
    @driver.navigate.to 'https://swarmsim.github.io/#/options'
    save = @driver.find_element(:id, "export").attribute("value")
    File.open('save', 'w') do |file|
      file.write(save)
    end
  end
end
