class Automaton
  class Tab
    def initialize(driver)
      @driver = driver
      while !loaded?
      end
      # -1 because we don't care about the meat tab
      @pages_count = @driver.find_elements(:css, ".unit-table tr").length - 1
    end

    def each_page
      @pages_count.times do |i|
        link = @driver.find_element(:css, ".unit-table tr:nth-child(#{i + 1}) .titlecase") rescue binding.pry
        link.click
        page = Page.new(@driver)
        yield(page)
      end
    end

    def reverse_each_page
      @pages_count.times do |j|
        i = @pages_count - j - 1
        link = @driver.find_element(:css, ".unit-table tr:nth-child(#{i + 1}) .titlecase") rescue binding.pry
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
end