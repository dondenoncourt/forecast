require 'rails_helper'

RSpec.describe ForecastService do
  describe '.forecast' do
    context 'when forecasting for zipcode 23192' do
      let(:zipcode) { '23192' }
      let(:location_result) { described_class.search_location(zipcode) }
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

      it 'returns an array of hashes' do
        # normally we would mock the response from the API, but for now we will just use the real API
        result = described_class.search_location(query)

        expect(result).to be_an(Array)
        expect(result).not_to be_empty
        expect(result.first).to be_a(Hash)
      end

      it 'returns a hash with expected keys' do
        result = described_class.search_location(query)

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

    context 'when searching for invalid zipcodes' do
      it 'returns an empty array when the zipcode is not 5 digits' do
        bad_zipcodes = ['99999', '00000', '00099', '00100', '11111']
        bad_zipcodes.each do |zipcode|
          result = described_class.search_location(zipcode)
          expect(result).to be_an(Array)
          expect(result).to be_empty
        end
      end
      it 'raises an error when the zipcode is not 5 digits' do
        expect { described_class.search_location('1234') }.to raise_error(ArgumentError, 'Zipcode must be 5 digits')
      end
    end

    context 'when searching for addresses' do
      it 'raises an error when the address is not in the format "City, ST"' do
        expect do
          described_class.search_location('13383 Spring Rd, Montpelier, VA 23192')
        end.to raise_error(ArgumentError,
          'Query must be a 5-digit zipcode or in the format \'City, ST\' (e.g., \'New York, NY\')')
      end
      context 'city, state format' do
        it 'uses the state to filter results' do
          result = described_class.search_location('Montpelier, VA')
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
