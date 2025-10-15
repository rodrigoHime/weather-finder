require 'rails_helper'
require "ostruct"

RSpec.describe Api::LocationsController, type: :request do
  describe 'GET /api/locations/search' do
    it 'calls LocationService and returns a list' do
      results = [
        OpenStruct.new(city: 'MV', state: 'CA', country: 'USA', zip: '94040', lat: 37.39, lon: -122.08, formatted_address: 'Mountain View, CA 94040, USA')
      ]

      expect(Api::LocationService).to receive(:search).with('94040').and_return(results)

      get '/api/locations/search', params: { q: '94040' }, headers: { 'ACCEPT' => 'application/json' }

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body).to be_an(Array)
      expect(body.first['zip']).to eq('94040')
    end

    it 'returns empty array when no results' do
      expect(Api::LocationService).to receive(:search).with('unknown').and_return([])

      get '/api/locations/search', params: { q: 'unknown' }, headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it 'returns 400 when q is missing' do
      get '/api/locations/search', headers: { 'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:bad_request)
    end
  end
end