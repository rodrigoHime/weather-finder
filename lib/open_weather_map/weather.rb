module OpenWeatherMap
  class Weather < Base
    include HTTParty
    base_uri "https://api.openweathermap.org/data/2.5"

    class << self
      def by_zip_code(zip_code, country_code)
        Rails.logger.info log_request_message("by_zip_code", zip_code, country_code)

        params = options({
                           zip: "#{zip_code},#{country_code}",
                           units: 'metric'
                         })
        get('/weather', params)
      end

      private

      def options(params)
        OpenWeatherMap.options(params)
      end

      def log_request_message(method, zip_code, country_code)
        "Requesting OpenWeatherMap::Weather #{method} with params: #{zip_code},#{country_code}"
      end

    end
  end
end