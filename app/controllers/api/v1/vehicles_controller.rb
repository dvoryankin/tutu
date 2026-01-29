class Api::V1::VehiclesController < Api::V1::BaseController
  skip_before_action :authenticate_api_user!, only: [:index, :show]

  def index
    @vehicles = Vehicle.includes(:route, :current_station)
    @vehicles = @vehicles.where(type: params[:type]) if params[:type].present?
    @vehicles = @vehicles.where(route_id: params[:route_id]) if params[:route_id].present?

    render json: {
      success: true,
      vehicles: @vehicles.map { |v| serialize_vehicle(v) }
    }
  end

  def show
    @vehicle = Vehicle.find(params[:id])

    render json: {
      success: true,
      vehicle: serialize_vehicle(@vehicle, include_compartments: true)
    }
  end

  private

  def serialize_vehicle(vehicle, include_compartments: false)
    data = {
      id: vehicle.id,
      number: vehicle.number,
      type: vehicle.type,
      route: vehicle.route&.name,
      current_station: vehicle.current_station&.title,
      available_seats: vehicle.available_seats,
      total_seats: vehicle.total_seats
    }

    if include_compartments
      data[:compartments] = vehicle.compartments.map do |comp|
        {
          id: comp.id,
          number: comp.number,
          class_type: comp.class_type,
          available_seats: comp.available_seats_count,
          total_seats: comp.total_seats,
          base_price: comp.base_price
        }
      end
    end

    data
  end
end
