class CreateStationsRoutes < ActiveRecord::Migration[7.0]
  def change
    create_table :stations_routes do |t|
      t.references :station, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true
      t.integer :position, default: 0
      t.time :arrival
      t.time :departure

      t.timestamps
    end

    add_index :stations_routes, [:station_id, :route_id], unique: true
    add_index :stations_routes, [:route_id, :position]
  end
end
