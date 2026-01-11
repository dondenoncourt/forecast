require 'httparty'

class ForecastService
  include HTTParty
  include ForecastHelper
  base_uri 'https://api.open-meteo.com/v1'

  # Get current weather and forecast for a location
  # @param latitude [Float] Latitude of the location
  # @param longitude [Float] Longitude of the location
  # @param zip [String] Zipcode of the location
  # @param days [Integer] Number of forecast days (default: 1, max: 16)
  # @return [Hash] Weather data including current conditions and forecast
  def self.forecast(latitude:, longitude:, zip:, days: 1)
    days = [days, 16].min # API max is 16 days

    cache_key = "forecast_#{zip}"

    Rails.cache.fetch(cache_key, expires_in: Rails.application.config.forecast_cache_expiration) do
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
    end
  rescue => e
    { error: "Forecast API error: #{e.message}" }
  end

  # Search for location by zipcode parsed from address
  # @param query [String] Address in format "123 Main St Apt 4B, Anytown, CA 90210"
  # @return [Array] Array of location results with :name, :country, :latitude, :longitude, :admin1 keys
  def self.search_location(query)
    address = parse_address(query)
    raise ArgumentError, "Invalid address format: #{query}" if address[:error]

    zip = address[:zip]

    response = HTTParty.get('https://geocoding-api.open-meteo.com/v1/search', query: {
      name: zip,
      count: 10,
      language: 'en',
      format: 'json',
      countryCode: 'US' # ingnore duplicate zipcodes in non-US countries
    })

    if response.success? && response['results']
      response['results'].map do |result|
        {
          name: result['name'],
          country: result['country'],
          latitude: result['latitude'],
          longitude: result['longitude'],
          state: result['admin1'],
          zip: result['postcode'] || zip
        }
      end
    else
      []
    end
  rescue ArgumentError
    raise # Re-raise validation errors
  rescue => e
    { error: "Geocoding API error: #{e.message}" }
  end

  # Parse response from OpenMeteo API (https://open-meteo.com/en/docs?hourly=#api_documentation)
  # @param API response from API
  # @return [Hash] with :current, :hourly, :location keys
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
      location: {
        latitude: response['latitude'],
        longitude: response['longitude'],
        timezone: response['timezone']
      }
    }
  end

  # Parse hourly data
  # @param hourly_data [Hash] Address in format "123 Main St Apt 4B, Anytown, CA 90210"
  # @return [Array] of hashes with :time, :temperature, :weather_code, :precipitation_probability keys
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

  # Parse full address
  # @param address [String] Address in format "123 Main St Apt 4B, Anytown, CA 90210"
  # @return [Hash] Hash with :street, :city, :state, :zip keys
  def self.parse_address(address)
    parts = address.split(/,\s+/)

    return { error: "Invalid address format" } if parts.length < 3

    street = parts[0].strip
    city = parts[1].strip
    state_zip = parts[2].strip

    state_zip_match = state_zip.match(/\A([A-Z]{2})\s+(\d{5})\z/)

    if state_zip_match
      state = state_zip_match[1]
      zip = state_zip_match[2]
    end

    {
      street: street,
      city: city,
      state: state,
      zip: zip
    }
  end
end
