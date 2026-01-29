class Api::V1::ProfilesController < Api::V1::BaseController
  def show
    render json: {
      success: true,
      profile: serialize_profile(current_user)
    }
  end

  def update
    if current_user.update(profile_params)
      render json: {
        success: true,
        profile: serialize_profile(current_user)
      }
    else
      render_error(current_user.errors.full_messages)
    end
  end

  def trips
    trips = current_user.past_trips.includes(:vehicle, :seat)

    render json: {
      success: true,
      trips: trips.map { |ticket| serialize_trip(ticket) }
    }
  end

  def upcoming
    trips = current_user.upcoming_trips.includes(:vehicle, :seat)

    render json: {
      success: true,
      trips: trips.map { |ticket| serialize_trip(ticket) }
    }
  end

  private

  def profile_params
    params.permit(:name, :last_name, :phone, :passport_number, :passport_expiry, :date_of_birth)
  end

  def serialize_profile(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      last_name: user.last_name,
      full_name: user.full_name,
      phone: user.phone,
      passport_number: user.passport_number,
      passport_expiry: user.passport_expiry,
      date_of_birth: user.date_of_birth,
      upcoming_trips_count: user.upcoming_trips.count,
      past_trips_count: user.past_trips.count
    }
  end

  def serialize_trip(ticket)
    {
      id: ticket.id,
      route_name: ticket.route_name,
      vehicle: ticket.vehicle&.display_name,
      seat: ticket.seat&.full_seat_number,
      passenger_name: ticket.passenger_name,
      departure_time: ticket.departure_time,
      arrival_time: ticket.arrival_time,
      price: ticket.price,
      status: ticket.status
    }
  end
end
