class SeatReservation
  attr_reader :seat, :user, :vehicle, :passenger_data, :ticket, :errors

  def initialize(seat:, user:, vehicle:, passenger_data: {})
    @seat = seat
    @user = user
    @vehicle = vehicle
    @passenger_data = passenger_data
    @errors = []
  end

  def reserve!
    return failure('Seat not found') unless seat
    return failure('Seat is not available') unless seat.available?
    return failure('User not found') unless user
    return failure('Vehicle not found') unless vehicle

    ActiveRecord::Base.transaction do
      seat.reserve!
      create_ticket!
      add_to_cart!
    end

    success
  rescue ActiveRecord::RecordInvalid => e
    seat.release! if seat.persisted?
    failure(e.message)
  rescue StandardError => e
    seat.release! if seat.persisted?
    failure("Reservation failed: #{e.message}")
  end

  def release!
    return failure('Seat not found') unless seat

    ActiveRecord::Base.transaction do
      seat.release!
      ticket&.cancel!
    end

    success
  rescue StandardError => e
    failure("Release failed: #{e.message}")
  end

  def success?
    errors.empty?
  end

  private

  def create_ticket!
    @ticket = Ticket.create!(
      user: user,
      vehicle: vehicle,
      seat: seat,
      passenger_name: passenger_data[:passenger_name] || user.full_name,
      passenger_passport: passenger_data[:passenger_passport] || user.passport_number,
      price: calculate_price,
      status: 'pending',
      departure_time: passenger_data[:departure_time],
      arrival_time: passenger_data[:arrival_time]
    )
  end

  def add_to_cart!
    cart = user.current_cart
    cart.add_ticket(ticket, ticket.price)
  end

  def calculate_price
    PriceCalculator.new(
      seat: seat,
      vehicle: vehicle
    ).calculate
  end

  def success
    true
  end

  def failure(message)
    @errors << message
    false
  end
end
