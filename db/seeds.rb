# TUTU Multimodal Transport Booking System - Seed Data
# Run with: rails db:seed

require 'securerandom'

puts "Seeding database..."

ActionMailer::Base.perform_deliveries = false

puts "Clearing existing data..."
CartItem.destroy_all
Cart.destroy_all
OrderItem.destroy_all
Order.destroy_all
Ticket.destroy_all
Seat.destroy_all
Compartment.destroy_all
Carriage.destroy_all
Vehicle.destroy_all
StationsRoute.destroy_all
RailwayStationsRoute.destroy_all
Route.destroy_all
FavoriteRoute.destroy_all
ApiToken.destroy_all
Station.destroy_all
RailwayStation.destroy_all

TARGETS = {
  railway_stations: 40,
  airports: 28,
  bus_stations: 30,
  train_routes: 60,
  flight_routes: 60,
  bus_routes: 60,
  trains: 100,
  planes: 100,
  buses: 100,
  schedule_days: 90
}.freeze

def ensure_route(name)
  route = Route.find_or_initialize_by(name: name)
  route.save!(validate: false) if route.new_record?
  route
end

def attach_stations(route, stations, legacy_map: nil)
  stations.each_with_index do |station, index|
    StationsRoute.find_or_create_by!(station: station, route: route) do |sr|
      sr.position = index
      base_time = Time.parse('06:00') + (index * 3).hours
      sr.arrival = base_time if index > 0
      sr.departure = base_time + 30.minutes
    end

    next unless legacy_map && station.type == 'RailwayStation'

    legacy_station = legacy_map[station.city]
    next unless legacy_station

    RailwayStationsRoute.find_or_create_by!(railway_station: legacy_station, route: route) do |rs|
      rs.position = index
      rs.arrival = (Time.parse('06:00') + (index * 3).hours).strftime('%H:%M') if index > 0
      rs.departure = (Time.parse('06:30') + (index * 3).hours).strftime('%H:%M')
    end
  end
end

puts "Creating stations..."

rail_cities = %w[
  Moscow Saint_Petersburg Novosibirsk Yekaterinburg Kazan Nizhny_Novgorod Samara Omsk Chelyabinsk Rostov_on_Don
  Ufa Volgograd Perm Krasnoyarsk Voronezh Saratov Tolyatti Izhevsk Barnaul Ulyanovsk Irkutsk Khabarovsk
  Yaroslavl Vladivostok Makhachkala Tomsk Orenburg Kemerovo Novokuznetsk Ryazan Astrakhan Penza
  Lipetsk Kirov Cheboksary Tula Kaliningrad Kursk Belgorod Sochi Tyumen
].map { |city| city.tr('_', ' ') }

railway_stations = []
legacy_railway_stations = {}

rail_cities.first(TARGETS[:railway_stations]).each do |city|
  legacy = RailwayStation.find_or_create_by!(title: "#{city} Railway Station")
  legacy_railway_stations[city] = legacy

  station = Station.create!(
    title: "#{city} Railway Station",
    city: city,
    type: 'RailwayStation'
  )
  railway_stations << station
end

puts "  Created #{railway_stations.count} railway stations"

airport_data = [
  ['Moscow', 'SVO', 'Sheremetyevo International Airport'],
  ['Moscow', 'DME', 'Domodedovo International Airport'],
  ['Moscow', 'VKO', 'Vnukovo International Airport'],
  ['Saint Petersburg', 'LED', 'Pulkovo Airport'],
  ['Novosibirsk', 'OVB', 'Tolmachevo Airport'],
  ['Yekaterinburg', 'SVX', 'Koltsovo Airport'],
  ['Kazan', 'KZN', 'Kazan International Airport'],
  ['Sochi', 'AER', 'Sochi International Airport'],
  ['Krasnodar', 'KRR', 'Pashkovsky Airport'],
  ['Ufa', 'UFA', 'Ufa International Airport'],
  ['Samara', 'KUF', 'Kurumoch Airport'],
  ['Perm', 'PEE', 'Perm International Airport'],
  ['Rostov-on-Don', 'ROV', 'Platov Airport'],
  ['Volgograd', 'VOG', 'Gumrak Airport'],
  ['Nizhny Novgorod', 'GOJ', 'Strigino Airport'],
  ['Kaliningrad', 'KGD', 'Khrabrovo Airport'],
  ['Vladivostok', 'VVO', 'Vladivostok Airport'],
  ['Khabarovsk', 'KHV', 'Khabarovsk Novy Airport'],
  ['Irkutsk', 'IKT', 'Irkutsk Airport'],
  ['Tyumen', 'TJM', 'Roshchino Airport'],
  ['Saratov', 'GSV', 'Gagarin Airport'],
  ['Astrakhan', 'ASF', 'Narimanovo Airport'],
  ['Murmansk', 'MMK', 'Murmansk Airport'],
  ['Arkhangelsk', 'ARH', 'Talagi Airport'],
  ['Yuzhno-Sakhalinsk', 'UUS', 'Yuzhno-Sakhalinsk Airport'],
  ['Mineralnye Vody', 'MRV', 'Mineralnye Vody Airport'],
  ['Omsk', 'OMS', 'Omsk Airport'],
  ['Chelyabinsk', 'CEK', 'Balandino Airport'],
  ['Barnaul', 'BAX', 'Barnaul Airport'],
  ['Tomsk', 'TOF', 'Tomsk Airport'],
  ['Orenburg', 'REN', 'Orenburg Airport']
]

airports = airport_data.first(TARGETS[:airports]).map do |city, code, title|
  Airport.create!(
    city: city,
    code: code,
    title: title
  )
end

puts "  Created #{airports.count} airports"

bus_cities = %w[
  Moscow Saint_Petersburg Kazan Nizhny_Novgorod Vladimir Yaroslavl Tver Ryazan Tula Smolensk Bryansk Kursk
  Belgorod Voronezh Lipetsk Tambov Saratov Volgograd Astrakhan Penza Samara Ufa Orenburg Cheboksary
  Izhevsk Kirov Perm Ulyanovsk Chelyabinsk Tyumen
].map { |city| city.tr('_', ' ') }

bus_stations = bus_cities.first(TARGETS[:bus_stations]).map do |city|
  BusStation.create!(
    title: "#{city} Bus Station",
    city: city
  )
end

puts "  Created #{bus_stations.count} bus stations"

puts "Creating routes..."

train_routes = []

special_train_pairs = [
  ['Samara', 'Yekaterinburg'],
  ['Moscow', 'Kazan'],
  ['Saint Petersburg', 'Moscow'],
  ['Novosibirsk', 'Omsk'],
  ['Perm', 'Ufa'],
  ['Krasnoyarsk', 'Irkutsk'],
  ['Chelyabinsk', 'Tyumen'],
  ['Rostov-on-Don', 'Volgograd']
]

special_train_pairs.each do |start_city, end_city|
  start_station = railway_stations.find { |s| s.city == start_city }
  end_station = railway_stations.find { |s| s.city == end_city }
  next unless start_station && end_station

  route = ensure_route("#{start_city} - #{end_city}")
  attach_stations(route, [start_station, end_station], legacy_map: legacy_railway_stations)
  train_routes << route
end

while train_routes.uniq.size < TARGETS[:train_routes]
  selected = railway_stations.sample(rand(2..5))
  next if selected.uniq.size < 2

  route = ensure_route("#{selected.first.city} - #{selected.last.city}")
  attach_stations(route, selected, legacy_map: legacy_railway_stations) if route.stations_routes.size < 2
  train_routes << route
end

train_routes.uniq!
puts "  Created #{train_routes.count} train routes"

flight_routes = []
while flight_routes.uniq.size < TARGETS[:flight_routes]
  selected = airports.sample(2)
  next if selected.uniq.size < 2

  route = ensure_route("#{selected.first.code} - #{selected.last.code}")
  attach_stations(route, selected)
  flight_routes << route
end

flight_routes.uniq!
puts "  Created #{flight_routes.count} flight routes"

bus_routes = []
while bus_routes.uniq.size < TARGETS[:bus_routes]
  selected = bus_stations.sample(rand(2..4))
  next if selected.uniq.size < 2

  route = ensure_route("#{selected.first.city} - #{selected.last.city} (Bus)")
  attach_stations(route, selected)
  bus_routes << route
end

bus_routes.uniq!
puts "  Created #{bus_routes.count} bus routes"

puts "Creating vehicles..."

TARGETS[:trains].times do |index|
  route = train_routes.sample
  train = Train.create!(
    number: "T#{1000 + index}",
    route: route,
    current_station: route.stations.first
  )

  classes = %w[economy coupe sitting lux].sample(2)
  classes.each do |class_type|
    compartment = TrainCompartment.create!(
      vehicle: train,
      class_type: class_type,
      base_price: rand(1200..3200)
    )
    compartment.generate_seats! if compartment.seats.empty?
  end
end

TARGETS[:planes].times do |index|
  route = flight_routes.sample
  plane = Plane.create!(
    number: "SU#{2000 + index}",
    route: route,
    current_station: route.stations.first
  )

  AirplaneCabin.create!(
    vehicle: plane,
    class_type: 'economy',
    base_price: rand(4500..9000)
  ).generate_seats!

  %w[business first].sample(1).each do |class_type|
    AirplaneCabin.create!(
      vehicle: plane,
      class_type: class_type,
      base_price: rand(12000..26000)
    ).generate_seats!
  end
end

TARGETS[:buses].times do |index|
  route = bus_routes.sample
  bus = Bus.create!(
    number: "B#{3000 + index}",
    route: route,
    current_station: route.stations.first
  )

  class_type = rand < 0.2 ? 'business' : 'economy'
  BusSection.create!(
    vehicle: bus,
    class_type: class_type,
    base_price: rand(500..1800)
  ).generate_seats!
end

puts "  Created #{Train.count} trains, #{Plane.count} planes, #{Bus.count} buses"

puts "Creating users..."

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

puts "Creating schedules (tickets)..."

users = [admin, user]
vehicles = Vehicle.includes(:route).to_a
start_date = Date.current
time_zone = Time.zone || ActiveSupport::TimeZone['UTC']

vehicles.each do |vehicle|
  TARGETS[:schedule_days].times do |offset|
    next unless ((vehicle.id + offset) % 3).zero?

    service_date = start_date + offset
    base_hour = 6 + (vehicle.id % 10)
    departure_time = time_zone.local(service_date.year, service_date.month, service_date.day, base_hour, (vehicle.id % 2) * 30)
    arrival_time = departure_time + rand(2..8).hours

    ticket_attrs = {
      user: users.sample,
      vehicle: vehicle,
      passenger_name: "Passenger #{SecureRandom.hex(3)}",
      passenger_passport: SecureRandom.random_number(10**10).to_s.rjust(10, '0'),
      price: rand(1200..12000),
      status: %w[pending confirmed].sample,
      departure_time: departure_time,
      arrival_time: arrival_time
    }

    if vehicle.is_a?(Train) && vehicle.route
      start_city = vehicle.route.start_station&.city
      end_city = vehicle.route.end_station&.city
      ticket_attrs[:start_station] = legacy_railway_stations[start_city] if start_city
      ticket_attrs[:end_station] = legacy_railway_stations[end_city] if end_city
    end

    Ticket.create!(ticket_attrs)
  end
end

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
puts "  - Seats: #{Seat.count}"
puts "  - Tickets: #{Ticket.count}"
puts ""
puts "Login credentials:"
puts "  Admin: admin@tutu.ru / password123"
puts "  User:  user@example.com / password123"
