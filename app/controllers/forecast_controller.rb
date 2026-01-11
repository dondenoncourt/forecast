class ForecastController < ApplicationController
  # Example: GET /forecast?lat=40.7128&lon=-74.0060
  # Example: GET /forecast?q=23192 or GET /forecast?q=New York, NY
  def show
    query = params[:q]

    @forecast = if query.present?
      @query = query
      # Search for location and get forecast from first result
      begin
        locations = ForecastService.search_location(query)
        if locations.is_a?(Array) && locations.any?
          location = locations.first
          ForecastService.forecast(latitude: location[:latitude], longitude: location[:longitude], zip: location[:zip])
        else
          { error: "Location not found. Please try a different search." }
        end
      rescue ArgumentError => e
        { error: e.message }
      end
    else
      { error: "Please provide a location query (q), or latitude and longitude parameters" }
    end

    respond_to do |format|
      format.html
      format.json { render json: @forecast }
    end
  end
end
