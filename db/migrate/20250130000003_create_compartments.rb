class CreateCompartments < ActiveRecord::Migration[7.0]
  def change
    create_table :compartments do |t|
      t.string :number
      t.string :type
      t.string :class_type, default: 'economy'
      t.references :vehicle, null: false, foreign_key: true
      t.integer :total_seats, default: 0
      t.decimal :base_price, precision: 10, scale: 2, default: 0

      t.timestamps
    end

    add_index :compartments, :type
    add_index :compartments, :class_type
    add_index :compartments, [:vehicle_id, :number], unique: true
  end
end
