require "ostruct"

class Api::WeatherService
  class CityNotFound < StandardError; end

  def initialize(zip_code, country_code)
    @zip_code = zip_code
    @country_code = country_code
    @cache_hit = false
  end

  def forecast!
    validate_args!
    response = cached do
      OpenWeatherMap::Weather.by_zip_code(@zip_code, @country_code)
    end
    parse_response(response)
  end

  def self.forecast(zip_code:, country_code:)
    new(zip_code, country_code).forecast!
  end

  private

  def validate_args!
    raise ArgumentError, "You must provide zip+country" if @zip_code.blank? || @country_code.blank?
  end

  def parse_response(response)
    raise CityNotFound, response["message"] if response["cod"] == "404"

    OpenStruct.new({
      data: OpenStruct.new(response),
      in_cache: @cache_hit
    })
  end

  def cache_key
    "forecast/#{@zip_code},#{@country_code}"
  end

  def cached
    cache_hit_occurred = true

    result = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      cache_hit_occurred = false
      yield
    end

    Rails.logger.info "Cache hit for key: #{cache_key}" if cache_hit_occurred

    @cache_hit = cache_hit_occurred
    result
  end

end