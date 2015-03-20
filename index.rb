require "selenium-webdriver"
require 'pry'

class Automaton
  class Tab
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

    def reverse_each_page
      @pages_count.times do |j|
        i = @pages_count - j - 1
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

  class Page
    def initialize(driver)
      @driver = driver
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

    def unit_type
      @driver.find_element(:tag_name, :h3).text
    end

    def unit_count
      @driver.find_element(:tag_name, "unit").find_element(:tag_name, "ng-pluralize").text.split[2].gsub(",", "").to_f
    end

    def available_count
      @driver.find_element(:tag_name, "buyunit").find_elements(:tag_name, "a").last.text.split.last.gsub(",", "").to_f
    end

    def buy_quarter
      if @driver.find_element(:tag_name, "buyunit").find_elements(:tag_name, "a").length == 3
        @driver.find_element(:tag_name, "buyunit").find_elements(:tag_name, "a")[1].click
      end
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
    Tab.new(@driver)
  end

  def territory_tab
    @driver.navigate.to 'https://swarmsim.github.io/#/tab/territory'
    Tab.new(@driver)
  end

  def larvae_page
    @driver.navigate.to "https://swarmsim.github.io/#/tab/larva/unit/larva"
    LarvaPage.new(@driver)
  end

  def ensure_scientific_format!
    @driver.navigate.to 'https://swarmsim.github.io/#/options'
    elem = @driver.find_element(:name, "00X") rescue nil
    while elem.nil?
      elem = @driver.find_element(:name, "00X") rescue nil
    end
    @driver.find_element(:name, "00X").click
  end

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

automaton = Automaton.new
automaton.ensure_scientific_format!
# automaton.reset!

loop do
  meat_tab = automaton.meat_tab
  meat_tab.each_page do |page|
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
      if page.available_count >= page.unit_count
        page.buy(page.unit_count)
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
        page.buy_production_upgrade!
      end
      if page.unit_count < 1.0e6
        page.buy_quarter
      end
    end
  end
end

automaton.close!