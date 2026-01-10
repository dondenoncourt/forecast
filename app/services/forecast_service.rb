require 'httparty'

class ForecastService
  include HTTParty
  include ForecastHelper
  base_uri 'https://api.open-meteo.com/v1'

  # Get current weather and forecast for a location
  # @param latitude [Float] Latitude of the location
  # @param longitude [Float] Longitude of the location
  # @param days [Integer] Number of forecast days (default: 1, max: 16)
  # @return [Hash] Weather data including current conditions and forecast
  def self.forecast(latitude:, longitude:, days: 1)
    days = [days, 16].min # API max is 16 days

    # Both current and hourly parameters are defined at
    #   https://open-meteo.com/en/docs?hourly=#hourly_parameter_definition
    response = get('/forecast', query: {
      latitude: latitude,
      longitude: longitude,
      temperature_unit: 'fahrenheit',
      wind_speed_unit: 'mph',
      precipitation_unit: 'inch',
      current: 'temperature_2m,weather_code,relative_humidity_2m',
      hourly: 'temperature_2m,weather_code,precipitation_probability',
      timezone: 'auto',
      forecast_days: days
    })

    if response.success?
      parse_response(response)
    else
      { error: "Failed to fetch weather data: #{response.code}" }
    end
  rescue => e
    { error: "Forecast API error: #{e.message}" }
  end

  # Search for location by name
  # @param query [String] Location name ("New York", "London")
  # @return [Array] Array of location results with coordinates
  def self.search_location(query)
    original_query = query.dup
    zipcode = query.match?(/\A\d+\z/)
    if zipcode && query.length != 5
      raise ArgumentError, "Zipcode must be 5 digits"
    end

    # If query is not all numeric, validate format: "city, 2-digit state code"
    if !zipcode && !query.match?(/\A.+, [A-Za-z]{2}\z/)
      raise ArgumentError, "Query must be a 5-digit zipcode or in the format 'City, ST' (e.g., 'New York, NY')"
    end

    if !zipcode
      city, state = query.split(/,\ /)
      query = city
      state = state.upcase
    end

    response = HTTParty.get('https://geocoding-api.open-meteo.com/v1/search', query: {
      name: query,
      count: 10,
      language: 'en',
      format: 'json',
      countryCode: 'US' # ingnore duplicate zipcodes in non-US countries
    })

    if response.success? && response['results']
      results = response['results'].map do |result|
        {
          name: result['name'],
          country: result['country'],
          latitude: result['latitude'],
          longitude: result['longitude'],
          admin1: result['admin1'] # State/Province
        }
      end
      if !zipcode
        results = results.select { |result| result[:admin1] == US_STATES[state] }
      end
      results
    else
      []
    end
  rescue ArgumentError
    raise # Re-raise validation errors
  rescue => e
    { error: "Geocoding API error: #{e.message}" }
  end

  def self.parse_response(response)
    {
      current: {
        temperature: response['current']['temperature_2m'],
        humidity: response['current']['relative_humidity_2m'],
        weather_code: response['current']['weather_code'],
        wind_speed: response['current']['wind_speed_10m'],
        time: response['current']['time']
      },
      hourly: parse_hourly(response['hourly']),
      # daily: parse_daily(response['daily']),
      location: {
        latitude: response['latitude'],
        longitude: response['longitude'],
        timezone: response['timezone']
      }
    }
  end

  def self.parse_hourly(hourly_data)
    return [] unless hourly_data

    hourly_data['time'].map.with_index do |time, index|
      {
        time: time,
        temperature: hourly_data['temperature_2m'][index],
        weather_code: hourly_data['weather_code'][index],
        precipitation_probability: hourly_data['precipitation_probability'][index]
      }
    end
  end
end
