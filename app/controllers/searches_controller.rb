class SearchesController < ApplicationController
  def show
    @search = Search.new
    @stations = Station.order(:title, :city)
    @transport_types = Search::TRANSPORT_TYPES
  end

  def create
    @search = Search.do(search_params)
    @stations = Station.order(:title, :city)
    @transport_types = Search::TRANSPORT_TYPES
    render :show
  end

  private

  def search_params
    params.require(:search).permit(:start_station_id, :end_station_id, :transport_type, :date)
  end
end
