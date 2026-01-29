class PriceCalculator
  attr_reader :seat, :vehicle, :compartment, :route, :options

  BASE_PRICES = {
    'Train' => 1500.0,
    'Plane' => 5000.0,
    'Bus' => 800.0
  }.freeze

  CLASS_MULTIPLIERS = {
    'economy' => 1.0,
    'business' => 1.8,
    'first' => 2.5,
    'coupe' => 1.5,
    'lux' => 3.0,
    'sitting' => 0.9
  }.freeze

  def initialize(seat: nil, vehicle: nil, compartment: nil, route: nil, options: {})
    @seat = seat
    @compartment = compartment || seat&.compartment
    @vehicle = vehicle || compartment&.vehicle
    @route = route || vehicle&.route
    @options = options
  end

  def calculate
    base = base_price
    base *= class_multiplier
    base *= seat_modifier if seat
    base *= route_multiplier if route
    base *= date_multiplier if options[:date]

    base.round(2)
  end

  def breakdown
    {
      base_price: base_price,
      class_multiplier: class_multiplier,
      seat_modifier: seat&.price_modifier || 1.0,
      route_multiplier: route_multiplier,
      date_multiplier: date_multiplier,
      final_price: calculate
    }
  end

  private

  def base_price
    return compartment.base_price if compartment&.base_price&.positive?

    vehicle_type = vehicle&.class&.name || 'Train'
    BASE_PRICES[vehicle_type] || BASE_PRICES['Train']
  end

  def class_multiplier
    class_type = compartment&.class_type || 'economy'
    CLASS_MULTIPLIERS[class_type] || 1.0
  end

  def seat_modifier
    seat&.price_modifier || 1.0
  end

  def route_multiplier
    return 1.0 unless route

    # Calculate multiplier based on route length (number of stations)
    stations_count = route.stations_routes.count
    stations_count = route.railway_stations_routes.count if stations_count.zero?

    case stations_count
    when 0..2 then 1.0
    when 3..5 then 1.2
    when 6..10 then 1.5
    else 2.0
    end
  end

  def date_multiplier
    return 1.0 unless options[:date]

    date = options[:date].to_date rescue Date.today
    day_of_week = date.wday

    # Weekend premium
    if day_of_week == 0 || day_of_week == 6
      1.15
    # Friday evening premium
    elsif day_of_week == 5
      1.1
    else
      1.0
    end
  end
end
