require 'rails_helper'

RSpec.describe ForecastController, type: :controller do
  describe 'GET #show' do
    let(:mock_forecast) do
      {
        current: {
          temperature: 72.5,
          humidity: 65,
          weather_code: 0,
          wind_speed: 5.0,
          time: '2024-01-01T12:00'
        },
        hourly: [],
        location: {
          latitude: 37.82125,
          longitude: -77.68443,
          timezone: 'America/New_York'
        },
        cached: false
      }
    end

    let(:mock_location) do
      {
        name: 'Montpelier',
        country: 'United States',
        latitude: 37.82125,
        longitude: -77.68443,
        state: 'Virginia',
        zip: '23192'
      }
    end

    context 'when query parameter is provided' do
      let(:query) { '13383 Spring Rd, Montpelier, VA 23192' }

      context 'when location is found' do
        before do
          allow(ForecastService).to receive(:search_location).with(query).and_return([mock_location])
          allow(ForecastService).to receive(:forecast).and_return(mock_forecast)
        end

        it 'returns successful response' do
          get :show, params: { q: query }
          expect(response).to have_http_status(:success)
        end

        it 'calls ForecastService.search_location with query' do
          get :show, params: { q: query }
          expect(ForecastService).to have_received(:search_location).with(query)
        end

        it 'calls ForecastService.forecast with location coordinates and zip' do
          get :show, params: { q: query }
          expect(ForecastService).to have_received(:forecast).with(
            latitude: mock_location[:latitude],
            longitude: mock_location[:longitude],
            zip: mock_location[:zip]
          )
        end

        it 'returns forecast as JSON' do
          get :show, params: { q: query }, format: :json
          json_response = JSON.parse(response.body)
          expect(json_response['current']['temperature']).to eq(72.5)
        end
      end

      context 'when location is not found' do
        before do
          allow(ForecastService).to receive(:search_location).with(query).and_return([])
        end

        it 'returns error message' do
          get :show, params: { q: query }
          expect(assigns(:forecast)[:error]).to eq('Location not found. Please try a different search.')
        end

        it 'returns successful response' do
          get :show, params: { q: query }
          expect(response).to have_http_status(:success)
        end
      end

      context 'when ArgumentError is raised' do
        before do
          allow(ForecastService).to receive(:search_location).with(query).and_raise(ArgumentError,
            'Invalid address format: test')
        end

        it 'handles ArgumentError and returns error message' do
          get :show, params: { q: query }
          expect(assigns(:forecast)[:error]).to eq('Invalid address format: test')
        end
      end
    end

    context 'when no query parameter is provided' do
      it 'returns error message' do
        get :show
        expect(assigns(:forecast)[:error]).to eq('Please provide a location query (q), or latitude and longitude parameters')
      end
    end

    context 'when query parameter is empty string' do
      it 'returns error message' do
        get :show, params: { q: '' }
        expect(assigns(:forecast)[:error]).to eq('Please provide a location query (q), or latitude and longitude parameters')
      end
    end
  end
end
