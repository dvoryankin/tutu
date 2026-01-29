class Api::V1::SearchesController < Api::V1::BaseController
  skip_before_action :authenticate_api_user!, only: [:create]

  def create
    search_service = TransportSearch.new(search_params)
    search_service.call

    render json: {
      success: true,
      results: {
        trains: serialize_vehicles(search_service.results[:trains]),
        planes: serialize_vehicles(search_service.results[:planes]),
        buses: serialize_vehicles(search_service.results[:buses])
      },
      total_count: search_service.total_count
    }
  end

  private

  def search_params
    params.permit(:start_station_id, :end_station_id, :transport_type, :date)
  end

  def serialize_vehicles(vehicles)
    vehicles.map do |vehicle|
      {
        id: vehicle.id,
        number: vehicle.number,
        type: vehicle.type,
        route: vehicle.route&.name,
        available_seats: vehicle.available_seats,
        total_seats: vehicle.total_seats
      }
    end
  end
end
