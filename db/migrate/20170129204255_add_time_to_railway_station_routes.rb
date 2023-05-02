class AddTimeToRailwayStationRoutes < ActiveRecord::Migration[7.0]
  def change
    add_column :railway_stations_routes, :arrival, :string
    add_column :railway_stations_routes, :departure, :string
  end
end
