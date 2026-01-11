require 'rails_helper'

RSpec.describe ForecastService do
  let(:don_address) { '13383 Spring Rd, Montpelier, VA 23192' }

  describe '.forecast' do
    context 'when forecasting for zipcode 23192' do
      let(:location_result) { described_class.search_location(don_address) }
      let(:latitude) { location_result.first[:latitude] }
      let(:longitude) { location_result.first[:longitude] }

      it 'returns a hash with expected keys' do
        result = described_class.forecast(latitude: latitude, longitude: longitude)
        expect(result).to be_a(Hash)
        expect(result[:current]).to be_a(Hash)
        expect(result[:current][:temperature]).to be_a(Float)
        expect(result[:current][:humidity]).to be_a(Integer)
        expect(result[:current][:weather_code]).to be_a(Integer)
        expect(result[:current][:time]).to be_a(String)
        expect(result[:hourly]).to be_an(Array)
        expect(result[:hourly].first).to be_a(Hash)
        expect(result[:hourly].first[:time]).to be_a(String)
        expect(result[:hourly].first[:temperature]).to be_a(Float)
        expect(result[:hourly].first[:weather_code]).to be_a(Integer)
        expect(result[:hourly].first[:precipitation_probability]).to be_a(Integer)
        expect(result[:location]).to be_a(Hash)
        expect(result[:location][:latitude]).to be_a(Float)
        expect(result[:location][:longitude]).to be_a(Float)
        expect(result[:location][:timezone]).to be_a(String)
      end
    end
  end

  describe '.search_location' do
    context 'when searching for zipcode 23192' do
      let(:query) { '23192' }

      it 'returns a hash with expected keys' do
        result = described_class.search_location(don_address)

        expect(result.first).to be_a(Hash)
        expect(result.first).to include(
          name: 'Montpelier',
          country: 'United States',
          latitude: 37.82125,
          longitude: -77.68443,
          admin1: 'Virginia'
        )
      end
    end

    context 'when searching for addresses' do
      it 'raises an error when the address is not in the format "City, ST"' do
        expect do
          described_class.search_location('bad, address')
        end.to raise_error(ArgumentError,
          'Invalid address format: bad, address')
      end
      context 'city, state format' do
        it 'uses the state to filter results' do
          result = described_class.search_location(don_address)
          expect(result).to be_an(Array)
          expect(result).not_to be_empty
          expect(result.first).to be_a(Hash)
          expect(result.first[:name]).to eq('Montpelier')
          expect(result.first[:admin1]).to eq('Virginia')
        end
      end
    end
  end
end
