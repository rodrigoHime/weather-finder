require "ostruct"

class Api::LocationService
  def initialize(query)
    @query = query
  end

  def search!
    response = GoogleApi::Geocoder.search(@query)
    parsed_response(response["results"])
  end

  def self.search(query)
    new(query).search!
  end

  private

  def parsed_response(results)
    results.map do |result|
      OpenStruct.new(
        city: result["address_components"].find { |c| c["types"].include?('administrative_area_level_2') }&.dig("long_name"),
        state: result["address_components"].find { |c| c["types"].include?('administrative_area_level_1') }&.dig("long_name"),
        country: result["address_components"].find { |c| c["types"].include?('country') }&.dig("long_name"),
        country_code:result["address_components"].find { |c| c["types"].include?('country') }&.dig("short_name"),
        zip: result["address_components"].find { |c| c["types"].include?('postal_code') }&.dig("long_name"),
        lat: result.dig("geometry", "location", "lat"),
        lon: result.dig("geometry", "location", "lng"),
        formatted_address: result.dig("formatted_address"),
      )
    end.reject { |result| result.zip.nil? }
  end

end