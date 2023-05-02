class RenameIndexStationToPosition < ActiveRecord::Migration[7.0]
  def change
    rename_column :railway_stations_routes, :index_station, :position
  end
end
