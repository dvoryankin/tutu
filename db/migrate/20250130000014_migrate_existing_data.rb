class MigrateExistingData < ActiveRecord::Migration[7.0]
  def up
    # Migrate railway_stations -> stations (type: 'RailwayStation')
    execute <<-SQL
      INSERT INTO stations (id, title, type, city, created_at, updated_at)
      SELECT id, title, 'RailwayStation', NULL, created_at, updated_at
      FROM railway_stations;
    SQL

    # Reset sequence for stations table (only if there's data)
    execute <<-SQL
      SELECT setval('stations_id_seq', GREATEST((SELECT COALESCE(MAX(id), 0) FROM stations), 1));
    SQL

    # Migrate trains -> vehicles (type: 'Train')
    execute <<-SQL
      INSERT INTO vehicles (id, number, type, route_id, current_station_id, created_at, updated_at)
      SELECT id, number, 'Train', route_id, current_station_id, created_at, updated_at
      FROM trains;
    SQL

    # Reset sequence for vehicles table (only if there's data)
    execute <<-SQL
      SELECT setval('vehicles_id_seq', GREATEST((SELECT COALESCE(MAX(id), 0) FROM vehicles), 1));
    SQL

    # Migrate railway_stations_routes -> stations_routes
    execute <<-SQL
      INSERT INTO stations_routes (station_id, route_id, position, arrival, departure, created_at, updated_at)
      SELECT railway_station_id, route_id, COALESCE(position, 0),
             CASE WHEN arrival IS NOT NULL AND arrival != '' THEN arrival::time ELSE NULL END,
             CASE WHEN departure IS NOT NULL AND departure != '' THEN departure::time ELSE NULL END,
             NOW(), NOW()
      FROM railway_stations_routes;
    SQL

    # Migrate carriages -> compartments
    execute <<-SQL
      INSERT INTO compartments (id, number, type, class_type, vehicle_id, total_seats, base_price, created_at, updated_at)
      SELECT
        id,
        number,
        CASE type
          WHEN 'CoupeCarriage' THEN 'TrainCompartment'
          WHEN 'EconomyCarriage' THEN 'TrainCompartment'
          WHEN 'SittingCarriage' THEN 'TrainCompartment'
          WHEN 'LuxCarriage' THEN 'TrainCompartment'
          ELSE 'TrainCompartment'
        END,
        CASE type
          WHEN 'CoupeCarriage' THEN 'coupe'
          WHEN 'EconomyCarriage' THEN 'economy'
          WHEN 'SittingCarriage' THEN 'sitting'
          WHEN 'LuxCarriage' THEN 'lux'
          ELSE 'economy'
        END,
        train_id,
        COALESCE(top_seats, 0) + COALESCE(bottom_seats, 0) +
        COALESCE(side_top_seats, 0) + COALESCE(side_bottom_seats, 0) +
        COALESCE(sitting_seats, 0),
        0,
        created_at,
        updated_at
      FROM carriages;
    SQL

    # Reset sequence for compartments table (only if there's data)
    execute <<-SQL
      SELECT setval('compartments_id_seq', GREATEST((SELECT COALESCE(MAX(id), 0) FROM compartments), 1));
    SQL

    # Update tickets to reference vehicles instead of trains
    execute <<-SQL
      UPDATE tickets
      SET vehicle_id = train_id,
          vehicle_type = 'Train'
      WHERE train_id IS NOT NULL;
    SQL
  end

  def down
    # Clear migrated data
    execute "DELETE FROM stations_routes;"
    execute "DELETE FROM compartments WHERE type = 'TrainCompartment';"
    execute "DELETE FROM vehicles WHERE type = 'Train';"
    execute "DELETE FROM stations WHERE type = 'RailwayStation';"

    # Reset tickets
    execute "UPDATE tickets SET vehicle_id = NULL, vehicle_type = NULL;"
  end
end
