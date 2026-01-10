class ForecastController < ApplicationController
  # Example: GET /forecast?lat=40.7128&lon=-74.0060
  def show
    latitude = params[:lat]&.to_f
    longitude = params[:lon]&.to_f

    @forecast = if latitude && longitude
      ForecastService.forecast(latitude: latitude, longitude: longitude)
    else
      { error: "Please provide latitude and longitude parameters" }
    end

    respond_to do |format|
      format.html
      format.json { render json: @forecast }
    end
  end

  # Example: GET /forecast/search?q=New York
  def search
    query = params[:q]

    @locations = if query.present?
      ForecastService.search_location(query)
    else
      []
    end

    respond_to do |format|
      format.html
      format.json { render json: @locations }
    end
  end
end
