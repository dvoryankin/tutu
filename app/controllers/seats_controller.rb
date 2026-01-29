class SeatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vehicle, only: [:index]
  before_action :set_seat, only: [:select, :release]

  def index
    @compartments = @vehicle.compartments.includes(:seats).ordered
  end

  def select
    reservation = SeatReservation.new(
      seat: @seat,
      user: current_user,
      vehicle: @seat.compartment.vehicle,
      passenger_data: passenger_params
    )

    if reservation.reserve!
      respond_to do |format|
        format.html { redirect_to cart_path, notice: 'Seat reserved and added to cart' }
        format.json { render json: { success: true, ticket_id: reservation.ticket.id } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: search_path, alert: reservation.errors.join(', ') }
        format.json { render json: { success: false, errors: reservation.errors }, status: :unprocessable_entity }
      end
    end
  end

  def release
    if @seat.release!
      respond_to do |format|
        format.html { redirect_back fallback_location: search_path, notice: 'Seat released' }
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: search_path, alert: 'Could not release seat' }
        format.json { render json: { success: false }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
  end

  def set_seat
    @seat = Seat.find(params[:id])
  end

  def passenger_params
    params.permit(:passenger_name, :passenger_passport, :departure_time, :arrival_time)
  end
end
