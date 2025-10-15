require 'rails_helper'

RSpec.describe Api::WeatherService do
  describe '#forecast' do
    context 'when zip_code and country_code are provided' do
      before { Rails.cache.clear }

      it 'queries by zip code via OpenWeatherMap::Weather.by_zip_code' do
        expect(OpenWeatherMap::Weather).to receive(:by_zip_code)
                                             .with('94040', 'US')
                                             .and_return({ 'cod' => '200', 'temp' => 295.0 })

        result = described_class.forecast(zip_code: '94040', country_code: 'US')
        expect(result.data.temp).to eq(295.0)
        expect(result.in_cache).to eq(false)
      end
    end

    context 'when neither zip nor coordinates are present' do
      it 'raises an informative error' do
        expect {
          described_class.forecast(zip_code: nil, country_code: nil)
        }.to raise_error(ArgumentError, /zip\+country/)
      end
    end
  end
end