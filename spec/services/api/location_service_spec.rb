require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Api::LocationService do
  describe '.search' do
    let(:query) { '94040' }

    it 'calls GoogleApi::Geocoder.search and maps results to OpenStructs' do
      payload = {
        'results' => [
          {
            'address_components' => [
              { 'types' => ['administrative_area_level_2'], 'long_name' => 'Mountain View' },
              { 'types' => ['administrative_area_level_1'], 'long_name' => 'California' },
              { 'types' => ['country'], 'long_name' => 'United States' },
              { 'types' => ['postal_code'], 'long_name' => '94040' }
            ],
            'geometry' => { 'location' => { 'lat' => 37.39, 'lng' => -122.08 } },
            'formatted_address' => 'Mountain View, CA 94040, USA'
          }
        ]
      }

      expect(GoogleApi::Geocoder).to receive(:search).with(query).and_return(payload)

      results = described_class.search(query)
      expect(results.length).to eq(1)
      obj = results.first
      expect(obj).to have_attributes(
                       city: 'Mountain View', state: 'California', country: 'United States', zip: '94040',
                       lat: 37.39, lon: -122.08, formatted_address: 'Mountain View, CA 94040, USA'
                     )
    end

    it 'filters out results without a zip code' do
      payload = { 'results' => [{ 'address_components' => [], 'geometry' => { 'location' => {} } }] }
      expect(GoogleApi::Geocoder).to receive(:search).and_return(payload)
      results = described_class.search(query)
      expect(results).to eq([])
    end

    it 'handles empty results' do
      expect(GoogleApi::Geocoder).to receive(:search).and_return({ 'results' => [] })
      expect(described_class.search(query)).to eq([])
    end
  end
end