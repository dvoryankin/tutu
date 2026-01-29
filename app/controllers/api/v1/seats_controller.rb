class Api::V1::SeatsController < Api::V1::BaseController
  skip_before_action :authenticate_api_user!, only: [:index]
  before_action :set_vehicle

  def index
    compartments = @vehicle.compartments.includes(:seats)

    render json: {
      success: true,
      compartments: compartments.map { |comp| serialize_compartment(comp) }
    }
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
  end

  def serialize_compartment(compartment)
    {
      id: compartment.id,
      number: compartment.number,
      class_type: compartment.class_type,
      seats: compartment.seats.order(:row, :position).map do |seat|
        {
          id: seat.id,
          seat_number: seat.seat_number,
          seat_type: seat.seat_type,
          row: seat.row,
          position: seat.position,
          available: seat.available,
          price: seat.price(compartment.base_price_for_class)
        }
      end
    }
  end
end
