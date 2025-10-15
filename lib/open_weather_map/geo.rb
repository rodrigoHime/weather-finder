module OpenWeatherMap
  class Geo
    include HTTParty
    base_uri 'https://api.openweathermap.org/geo/1.0'

    class << self
      def search(location)
        params = options({
                           q: location,
                           limit: 5
                         })
        get("/direct", params)
      end

      def by_zip_code(zip_code, country_code)
        params = options({
                           zip: "#{zip_code},#{country_code}"
                         })
        get("/zip", params)
      end

      def by_lat_lon(lat, lon)
        params = options({
                           lat: lat,
                           lon: lon,
                           limit: 5
                         })
        get("/reverse", params)
      end

      private

      def options(params)
        OpenWeatherMap.options(params)
      end
    end
  end
end