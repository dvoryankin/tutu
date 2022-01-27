# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# rs1 = RailwayStation.new(id:1, title: 'Omsk')
# rs2 = RailwayStation.new(id: 2, title: 'Moscow')
# t1 = Train.new(number: '123')
# r1 = Route.new(name: 'Omsk - Moscow')
# r1.railway_stations << rs1
# r1.railway_stations << rs2
# t1.current_station << rs1
# ActiveRecord::Migration.drop_table(:trains)
# ActiveRecord::Migration.create_table(:trains)
#
# ActiveRecord::Migration.drop_table(:routes)
# ActiveRecord::Migration.create_table(:routes)
#
# ActiveRecord::Migration.drop_table(:users)
# ActiveRecord::Migration.create_table(:users)
#
# ActiveRecord::Migration.drop_table(:railway_stations)
# ActiveRecord::Migration.create_table(:railway_stations)
#
# ActiveRecord::Migration.drop_table(:tickets)
# ActiveRecord::Migration.create_table(:tickets)
#
# ActiveRecord::Migration.drop_table(:carriages)
# ActiveRecord::Migration.create_table(:carriages)
#
#
#
#
20.times do
  RailwayStation.create(
      title: Faker::Address.city
  )
end

10.times do
  Route.create(
      name: "#{Faker::Address.city} - #{Faker::Address.city}"
  )
end

10.times do
  Train.create(
      number: Faker::Address.building_number
  )
end

route_1 = Route.new
route_1.railway_stations << RailwayStation.first
route_1.railway_stations << RailwayStation.second
route_1.save

10.times do
  route = Route.new
  rand_station1 = RailwayStation.order(Arel.sql('RANDOM()')).first
  rand_station2 = RailwayStation.order(Arel.sql('RANDOM()')).first
  if rand_station1 == rand_station2
    rand_station2 = RailwayStation.order(Arel.sql('RANDOM()')).first
  end

  route.railway_stations << rand_station1
  route.railway_stations << rand_station2
  route.name = "#{rand_station1.title} - #{rand_station2.title}"
  route.save
end
