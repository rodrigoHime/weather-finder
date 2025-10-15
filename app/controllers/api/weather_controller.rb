class Api::WeatherController < Api::ApiController
  rescue_from Api::WeatherService::CityNotFound, with: :handle_city_not_found_error

  def forecast
    @forecast = Api::WeatherService.forecast(
      zip_code: forecast_params[:zip_code],
      country_code: forecast_params[:country_code]
    )
  end

  private

  def handle_city_not_found_error(e)
    render json: { error: e.message }, status: :not_found
  end

  def forecast_params
    params.permit(:zip_code, :country_code)
  end
end