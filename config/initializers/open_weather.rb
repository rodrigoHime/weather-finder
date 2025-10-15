require "#{Rails.root}/lib/open_weather_map/open_weather_map.rb"

OpenWeatherMap.configure do |config|
  config.api_key = Rails.application.credentials.config[:open_weather_api_key]
end
