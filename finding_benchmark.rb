require_relative "lib/automaton"
require "benchmark/ips"

@driver = Selenium::WebDriver.for :firefox
@driver.navigate.to "https://swarmsim.github.io"

# i should figure out to just wait as much as I need
sleep 3

Benchmark.ips do |x|
  x.report("find by combined classes and tags") do
    @driver.find_element(:tag_name, "tabs").find_elements(:class, "tab-resource")[1].find_element(:class, "glyphicon-circle-arrow-up") rescue nil
  end

  x.report("find by css") do
    @driver.find_element(:css, "tabs .tab-resource:nth-child(3) .glyphicon-circle-arrow-up") rescue nil
  end
end

# Not very surprising
# Calculating -------------------------------------
# find by combined classes and tags
#                          1.000  i/100ms
#          find by css     1.000  i/100ms
# -------------------------------------------------
# find by combined classes and tags
#                           5.629  (±17.8%) i/s -     29.000
#          find by css     17.626  (±22.7%) i/s -     84.000