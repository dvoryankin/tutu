# Regular routes seed - adds daily scheduled services on popular routes
# Run with: rails runner db/seeds/regular_routes.rb

puts "Creating regular scheduled routes..."

ActionMailer::Base.perform_deliveries = false

user = User.first
time_zone = Time.zone || ActiveSupport::TimeZone['UTC']
start_date = Date.today
end_date = Date.today + 180

# Helper to find or create route with validation bypass
def ensure_route(name, from_station, to_station)
  route = Route.find_by(name: name)
  return route if route

  route = Route.new(name: name)
  route.save!(validate: false)

  StationsRoute.find_or_create_by!(station: from_station, route: route, position: 0)
  StationsRoute.find_or_create_by!(station: to_station, route: route, position: 1)

  route
end

# Helper to create vehicle with compartments
def ensure_vehicle(type_class, number, route)
  vehicle = type_class.find_by(number: number)
  return vehicle if vehicle

  vehicle = type_class.create!(number: number, route: route, current_station: route.stations.first)

  case type_class.name
  when 'Train'
    TrainCompartment.create!(vehicle: vehicle, class_type: 'economy', base_price: 2500).generate_seats!
    TrainCompartment.create!(vehicle: vehicle, class_type: 'coupe', base_price: 4500).generate_seats!
  when 'Plane'
    AirplaneCabin.create!(vehicle: vehicle, class_type: 'economy', base_price: 5000).generate_seats!
    AirplaneCabin.create!(vehicle: vehicle, class_type: 'business', base_price: 15000).generate_seats!
  when 'Bus'
    BusSection.create!(vehicle: vehicle, class_type: 'economy', base_price: 1500).generate_seats!
  end

  vehicle
end

created = 0

# === TRAINS ===
puts "  Creating train schedules..."

train_routes = [
  { from: 'Moscow', to: 'Saint Petersburg', times: ['06:00', '10:00', '14:00', '18:00', '22:00'], duration: 4 },
  { from: 'Moscow', to: 'Kazan', times: ['07:00', '15:00', '23:00'], duration: 12 },
  { from: 'Moscow', to: 'Nizhny Novgorod', times: ['08:00', '12:00', '17:00'], duration: 4 },
  { from: 'Saint Petersburg', to: 'Moscow', times: ['06:00', '10:00', '14:00', '18:00', '22:00'], duration: 4 },
]

train_routes.each_with_index do |r, ri|
  from = Station.find_by(city: r[:from], type: 'RailwayStation')
  to = Station.find_by(city: r[:to], type: 'RailwayStation')
  next unless from && to

  route = ensure_route("REG: #{r[:from]} - #{r[:to]}", from, to)

  r[:times].each_with_index do |dep_time, ti|
    vehicle = ensure_vehicle(Train, "REG#{100 + ri * 10 + ti}", route)
    hour, min = dep_time.split(':').map(&:to_i)

    (start_date..end_date).each do |date|
      departure = time_zone.local(date.year, date.month, date.day, hour, min)
      next if Ticket.exists?(vehicle: vehicle, departure_time: departure.beginning_of_day..departure.end_of_day)

      Ticket.create!(
        user: user,
        vehicle: vehicle,
        passenger_name: "Schedule",
        passenger_passport: "0000000000",
        price: 2500,
        status: 'confirmed',
        departure_time: departure,
        arrival_time: departure + r[:duration].hours
      )
      created += 1
    end
  end
  print "."
end
puts ""

# === PLANES ===
puts "  Creating flight schedules..."

flight_routes = [
  { from: 'SVO', to: 'LED', times: ['07:00', '10:00', '13:00', '16:00', '19:00', '22:00'], duration: 1.5 },
  { from: 'LED', to: 'SVO', times: ['07:00', '10:00', '13:00', '16:00', '19:00', '22:00'], duration: 1.5 },
  { from: 'SVO', to: 'AER', times: ['08:00', '12:00', '16:00', '20:00'], duration: 2.5 },
  { from: 'AER', to: 'SVO', times: ['09:00', '13:00', '17:00', '21:00'], duration: 2.5 },
  { from: 'DME', to: 'LED', times: ['06:30', '11:30', '17:30'], duration: 1.5 },
]

flight_routes.each_with_index do |r, ri|
  from = Station.find_by(code: r[:from], type: 'Airport')
  to = Station.find_by(code: r[:to], type: 'Airport')
  next unless from && to

  route = ensure_route("SU: #{r[:from]} - #{r[:to]}", from, to)

  r[:times].each_with_index do |dep_time, ti|
    vehicle = ensure_vehicle(Plane, "SU#{500 + ri * 10 + ti}", route)
    hour, min = dep_time.split(':').map(&:to_i)

    (start_date..end_date).each do |date|
      departure = time_zone.local(date.year, date.month, date.day, hour, min)
      next if Ticket.exists?(vehicle: vehicle, departure_time: departure.beginning_of_day..departure.end_of_day)

      Ticket.create!(
        user: user,
        vehicle: vehicle,
        passenger_name: "Schedule",
        passenger_passport: "0000000000",
        price: 5000,
        status: 'confirmed',
        departure_time: departure,
        arrival_time: departure + r[:duration].hours
      )
      created += 1
    end
  end
  print "."
end
puts ""

# === BUSES ===
puts "  Creating bus schedules..."

bus_routes = [
  { from: 'Moscow', to: 'Saint Petersburg', times: ['06:00', '10:00', '14:00', '20:00'], duration: 10 },
  { from: 'Saint Petersburg', to: 'Moscow', times: ['06:00', '10:00', '14:00', '20:00'], duration: 10 },
  { from: 'Moscow', to: 'Nizhny Novgorod', times: ['07:00', '11:00', '15:00', '19:00'], duration: 6 },
]

bus_routes.each_with_index do |r, ri|
  from = Station.find_by(city: r[:from], type: 'BusStation')
  to = Station.find_by(city: r[:to], type: 'BusStation')
  next unless from && to

  route = ensure_route("BUS: #{r[:from]} - #{r[:to]}", from, to)

  r[:times].each_with_index do |dep_time, ti|
    vehicle = ensure_vehicle(Bus, "BUS#{800 + ri * 10 + ti}", route)
    hour, min = dep_time.split(':').map(&:to_i)

    (start_date..end_date).each do |date|
      departure = time_zone.local(date.year, date.month, date.day, hour, min)
      next if Ticket.exists?(vehicle: vehicle, departure_time: departure.beginning_of_day..departure.end_of_day)

      Ticket.create!(
        user: user,
        vehicle: vehicle,
        passenger_name: "Schedule",
        passenger_passport: "0000000000",
        price: 1500,
        status: 'confirmed',
        departure_time: departure,
        arrival_time: departure + r[:duration].hours
      )
      created += 1
    end
  end
  print "."
end
puts ""

puts ""
puts "=" * 50
puts "Created #{created} scheduled tickets"
puts "=" * 50
puts ""
puts "Now you can search for:"
puts "  TRAINS: Moscow <-> Saint Petersburg, Moscow -> Kazan, Moscow -> Nizhny Novgorod"
puts "  PLANES: SVO <-> LED, SVO <-> AER (Sochi), DME -> LED"
puts "  BUSES: Moscow <-> Saint Petersburg, Moscow -> Nizhny Novgorod"
puts ""
puts "Available for dates: #{start_date} to #{end_date}"
