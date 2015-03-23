class EventsController < ApplicationController
  protect_from_forgery :except => :create

  def index
    render json: Event.all
  end

  def create
    Event.create(event_params)
    render nothing: true
  end

  private

  def event_params
    params.require(:event).permit(:event_type, :unit_type, :unit_count)
  end
end
