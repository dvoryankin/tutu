class CreateVehicles < ActiveRecord::Migration[7.0]
  def change
    create_table :vehicles do |t|
      t.string :number, null: false
      t.string :type, null: false
      t.references :route, foreign_key: true
      t.references :current_station, foreign_key: { to_table: :stations }

      t.timestamps
    end

    add_index :vehicles, :type
    add_index :vehicles, [:number, :type], unique: true
  end
end
