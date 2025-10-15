require "#{Rails.root}/lib/open_weather_map/api.rb"

OpenWeatherMap.configure do |config|
  config.api_key = Rails.application.credentials.config[:open_weather_api_key]
end
