module GoogleApi
  class Geocoder < Base
    include HTTParty
    base_uri "https://maps.googleapis.com/maps/api/geocode"

    class << self
      def search(address)
        params = options({
                           address: address
                         })
        get("/json", params)
      end

      private

      def options(params)
        GoogleApi.Base.options(params)
      end
    end
  end
end