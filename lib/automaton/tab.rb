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
end