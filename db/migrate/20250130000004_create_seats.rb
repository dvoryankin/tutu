class CreateSeats < ActiveRecord::Migration[7.0]
  def change
    create_table :seats do |t|
      t.references :compartment, null: false, foreign_key: true
      t.string :seat_number, null: false
      t.string :seat_type
      t.integer :row
      t.string :position
      t.boolean :available, default: true
      t.decimal :price_modifier, precision: 5, scale: 2, default: 1.0

      t.timestamps
    end

    add_index :seats, [:compartment_id, :seat_number], unique: true
    add_index :seats, :available
    add_index :seats, :seat_type
  end
end
