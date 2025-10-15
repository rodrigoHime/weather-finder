class Api::LocationsController < Api::ApiController
  def search
    q = search_params[:q]
    return head :bad_request if q.blank?

    @locations = Api::LocationService.search(q)
  end

  private

  def search_params
    params.permit(:q)
  end
end

