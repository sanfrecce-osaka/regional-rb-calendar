ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"])

require "open-uri"
require "json"

require_relative "./lib/event_calendar"

class App < Sinatra::Base
  configure do
    mime_type :ics, "text/calendar"
  end

  get "/" do
    "It works"
  end

  get "/api/calendar/:site.ics" do
    content_type :ics

    config_file = File.join(__dir__, "docs", "config", "#{params[:site]}.json")
    halt 404 unless File.exists?(config_file)

    config = JSON.parse(File.read(config_file))

    calendar = App.calendar(params[:site], config["title"])
    calendar.generate_ical(config["groups"])
  end

  # @return [EventCalendar]
  def self.calendar(site, title)
    EventCalendar.new(site: site, title: title)
  end
end
