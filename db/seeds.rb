# TUTU Multimodal Transport Booking System - Seed Data
# Run with: rails db:seed

puts "Seeding database..."

# Clear existing data (optional - comment out in production)
# Order matters due to foreign keys
puts "Clearing existing data..."
CartItem.destroy_all
Cart.destroy_all
OrderItem.destroy_all
Order.destroy_all
Ticket.destroy_all
Seat.destroy_all
Compartment.destroy_all
Vehicle.destroy_all
StationsRoute.destroy_all
FavoriteRoute.destroy_all
ApiToken.destroy_all

puts "Creating stations..."

# Railway Stations (using raw insert to avoid STI conflict with existing RailwayStation model)
railway_cities = ['Moscow', 'Saint Petersburg', 'Novosibirsk', 'Yekaterinburg', 'Kazan', 'Nizhny Novgorod', 'Samara', 'Omsk', 'Chelyabinsk', 'Rostov-on-Don']
railway_stations = railway_cities.map do |city|
  station = Station.find_by(title: "#{city} Railway Station", type: 'RailwayStation')
  unless station
    station = Station.new
    station.title = "#{city} Railway Station"
    station.city = city
    station[:type] = 'RailwayStation'  # Set type directly to avoid STI lookup
    station.save!
  end
  station
end
puts "  Created #{railway_stations.count} railway stations"

# Airports
airports_data = [
  { city: 'Moscow', title: 'Sheremetyevo International Airport', code: 'SVO' },
  { city: 'Moscow', title: 'Domodedovo International Airport', code: 'DME' },
  { city: 'Saint Petersburg', title: 'Pulkovo Airport', code: 'LED' },
  { city: 'Novosibirsk', title: 'Tolmachevo Airport', code: 'OVB' },
  { city: 'Yekaterinburg', title: 'Koltsovo Airport', code: 'SVX' },
  { city: 'Kazan', title: 'Kazan International Airport', code: 'KZN' },
  { city: 'Sochi', title: 'Sochi International Airport', code: 'AER' },
  { city: 'Krasnodar', title: 'Pashkovsky Airport', code: 'KRR' }
]
airports = airports_data.map do |data|
  Airport.find_or_create_by!(code: data[:code]) do |a|
    a.title = data[:title]
    a.city = data[:city]
  end
end
puts "  Created #{airports.count} airports"

# Bus Stations
bus_cities = ['Moscow', 'Saint Petersburg', 'Kazan', 'Nizhny Novgorod', 'Vladimir', 'Yaroslavl', 'Tver', 'Ryazan']
bus_stations = bus_cities.map do |city|
  BusStation.find_or_create_by!(title: "#{city} Bus Station") do |s|
    s.city = city
  end
end
puts "  Created #{bus_stations.count} bus stations"

puts "Creating routes..."

# Helper to find station by city
def find_railway_station(city)
  Station.find_by(city: city, type: 'RailwayStation')
end

# Train Routes
train_routes_data = [
  { name: 'Moscow - Saint Petersburg', cities: ['Moscow', 'Saint Petersburg'] },
  { name: 'Moscow - Kazan', cities: ['Moscow', 'Nizhny Novgorod', 'Kazan'] },
  { name: 'Moscow - Novosibirsk', cities: ['Moscow', 'Kazan', 'Yekaterinburg', 'Omsk', 'Novosibirsk'] },
  { name: 'Saint Petersburg - Kazan', cities: ['Saint Petersburg', 'Moscow', 'Nizhny Novgorod', 'Kazan'] }
]

train_routes_data.each do |route_data|
  route = Route.find_or_initialize_by(name: route_data[:name])
  route.save!(validate: false) if route.new_record?
  route_data[:cities].each_with_index do |city, index|
    station = find_railway_station(city)
    next unless station
    StationsRoute.find_or_create_by!(station: station, route: route) do |sr|
      sr.position = index
      sr.arrival = Time.parse("#{6 + index * 3}:00") if index > 0
      sr.departure = Time.parse("#{6 + index * 3}:30")
    end
  end
end
puts "  Created #{train_routes_data.count} train routes"

# Flight Routes
flight_routes = [
  { name: 'Moscow (SVO) - Saint Petersburg', start: 'SVO', end_code: 'LED' },
  { name: 'Moscow (DME) - Sochi', start: 'DME', end_code: 'AER' },
  { name: 'Moscow (SVO) - Novosibirsk', start: 'SVO', end_code: 'OVB' },
  { name: 'Saint Petersburg - Kazan', start: 'LED', end_code: 'KZN' },
  { name: 'Moscow (SVO) - Yekaterinburg', start: 'SVO', end_code: 'SVX' }
]

flight_routes.each do |route_data|
  route = Route.find_or_initialize_by(name: route_data[:name])
  route.save!(validate: false) if route.new_record?
  start_airport = Airport.find_by(code: route_data[:start])
  end_airport = Airport.find_by(code: route_data[:end_code])
  next unless start_airport && end_airport

  StationsRoute.find_or_create_by!(station: start_airport, route: route) do |sr|
    sr.position = 0
    sr.departure = Time.parse("08:00")
  end
  StationsRoute.find_or_create_by!(station: end_airport, route: route) do |sr|
    sr.position = 1
    sr.arrival = Time.parse("10:30")
  end
end
puts "  Created #{flight_routes.count} flight routes"

# Bus Routes
bus_routes_data = [
  { name: 'Moscow - Vladimir (Bus)', cities: ['Moscow', 'Vladimir'] },
  { name: 'Moscow - Yaroslavl (Bus)', cities: ['Moscow', 'Yaroslavl'] },
  { name: 'Moscow - Ryazan (Bus)', cities: ['Moscow', 'Ryazan'] },
  { name: 'Saint Petersburg - Tver (Bus)', cities: ['Saint Petersburg', 'Tver'] }
]

bus_routes_data.each do |route_data|
  route = Route.find_or_initialize_by(name: route_data[:name])
  route.save!(validate: false) if route.new_record?
  route_data[:cities].each_with_index do |city, index|
    station = BusStation.find_by(city: city)
    next unless station
    StationsRoute.find_or_create_by!(station: station, route: route) do |sr|
      sr.position = index
      sr.arrival = Time.parse("#{7 + index * 2}:00") if index > 0
      sr.departure = Time.parse("#{7 + index * 2}:15")
    end
  end
end
puts "  Created #{bus_routes_data.count} bus routes"

puts "Creating vehicles..."

# Trains
trains_data = [
  { number: '001A', route: 'Moscow - Saint Petersburg' },
  { number: '002A', route: 'Moscow - Saint Petersburg' },
  { number: '015B', route: 'Moscow - Kazan' },
  { number: '099C', route: 'Moscow - Novosibirsk' }
]

trains_data.each do |train_data|
  route = Route.find_by(name: train_data[:route])
  next unless route

  train = Train.find_or_create_by!(number: train_data[:number]) do |t|
    t.route = route
    t.current_station = route.stations.first
  end

  # Create compartments with seats
  [
    { class_type: 'lux', base_price: 8000 },
    { class_type: 'coupe', base_price: 4000 },
    { class_type: 'coupe', base_price: 4000 },
    { class_type: 'economy', base_price: 2000 },
    { class_type: 'economy', base_price: 2000 },
    { class_type: 'sitting', base_price: 1500 }
  ].each do |comp_data|
    comp = train.compartments.find_or_create_by!(class_type: comp_data[:class_type], type: 'TrainCompartment') do |c|
      c.base_price = comp_data[:base_price]
    end
    comp.generate_seats! if comp.seats.empty? && comp.respond_to?(:generate_seats!)
  end
end
puts "  Created #{Train.count} trains"

# Planes
planes_data = [
  { number: 'SU-100', route: 'Moscow (SVO) - Saint Petersburg' },
  { number: 'SU-200', route: 'Moscow (DME) - Sochi' },
  { number: 'S7-300', route: 'Moscow (SVO) - Novosibirsk' },
  { number: 'DP-400', route: 'Saint Petersburg - Kazan' }
]

planes_data.each do |plane_data|
  route = Route.find_by(name: plane_data[:route])
  next unless route

  plane = Plane.find_or_create_by!(number: plane_data[:number]) do |p|
    p.route = route
    p.current_station = route.stations.first
  end

  # Create cabins with seats
  [
    { class_type: 'first', base_price: 25000 },
    { class_type: 'business', base_price: 15000 },
    { class_type: 'economy', base_price: 5000 }
  ].each do |cabin_data|
    cabin = plane.compartments.find_or_create_by!(class_type: cabin_data[:class_type], type: 'AirplaneCabin') do |c|
      c.base_price = cabin_data[:base_price]
    end
    cabin.generate_seats! if cabin.seats.empty? && cabin.respond_to?(:generate_seats!)
  end
end
puts "  Created #{Plane.count} planes"

# Buses
buses_data = [
  { number: 'BUS-101', route: 'Moscow - Vladimir (Bus)' },
  { number: 'BUS-102', route: 'Moscow - Yaroslavl (Bus)' },
  { number: 'BUS-103', route: 'Moscow - Ryazan (Bus)' }
]

buses_data.each do |bus_data|
  route = Route.find_by(name: bus_data[:route])
  next unless route

  bus = Bus.find_or_create_by!(number: bus_data[:number]) do |b|
    b.route = route
    b.current_station = route.stations.first
  end

  # Create sections with seats
  [
    { class_type: 'economy', base_price: 800 }
  ].each do |section_data|
    section = bus.compartments.find_or_create_by!(class_type: section_data[:class_type], type: 'BusSection') do |c|
      c.base_price = section_data[:base_price]
    end
    section.generate_seats! if section.seats.empty? && section.respond_to?(:generate_seats!)
  end
end
puts "  Created #{Bus.count} buses"

puts "Creating users..."

# Admin user
admin = User.find_or_initialize_by(email: 'admin@tutu.ru')
admin.assign_attributes(
  name: 'Admin',
  last_name: 'User',
  password: 'password123',
  password_confirmation: 'password123',
  admin: true,
  phone: '+7 999 000 0001',
  passport_number: '1234 567890',
  passport_expiry: Date.today + 5.years,
  date_of_birth: Date.new(1985, 1, 15)
)
admin.skip_confirmation!
admin.save!
puts "  Admin user created: admin@tutu.ru / password123"

# Regular user
user = User.find_or_initialize_by(email: 'user@example.com')
user.assign_attributes(
  name: 'Test',
  last_name: 'User',
  password: 'password123',
  password_confirmation: 'password123',
  admin: false,
  phone: '+7 999 000 0002',
  passport_number: '9876 543210',
  passport_expiry: Date.today + 3.years,
  date_of_birth: Date.new(1990, 6, 20)
)
user.skip_confirmation!
user.save!
puts "  Regular user created: user@example.com / password123"

puts ""
puts "=" * 50
puts "Seeding complete!"
puts "=" * 50
puts ""
puts "Summary:"
puts "  - Railway Stations: #{Station.where(type: 'RailwayStation').count}"
puts "  - Airports: #{Airport.count}"
puts "  - Bus Stations: #{BusStation.count}"
puts "  - Routes: #{Route.count}"
puts "  - Trains: #{Train.count}"
puts "  - Planes: #{Plane.count}"
puts "  - Buses: #{Bus.count}"
puts "  - Total Seats: #{Seat.count}"
puts "  - Users: #{User.count}"
puts ""
puts "Login credentials:"
puts "  Admin: admin@tutu.ru / password123"
puts "  User:  user@example.com / password123"
