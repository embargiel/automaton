class EventsController < ApplicationController
  protect_from_forgery :except => :create

  def create
    puts "received #{params}"
    render nothing: true
  end
end
