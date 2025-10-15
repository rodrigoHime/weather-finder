module OpenWeatherMap
  module Base
    class << self
      attr_accessor :api_key

      def configure
        yield self
      end

      def options(params)
        { query: params.merge(appid: api_key) }
      end
    end
  end
end