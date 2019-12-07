class GenericController < ApplicationController
  def country_code
    results = Geocoder.search(coords)
    render json: { results: results.first.country_code }
  end

  private

  def coords
    lat = params[:lat]
    long = params[:long]
    [lat, long]
  end
end
