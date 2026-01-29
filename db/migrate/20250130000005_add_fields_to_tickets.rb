class AddFieldsToTickets < ActiveRecord::Migration[7.0]
  def change
    add_column :tickets, :vehicle_id, :bigint
    add_column :tickets, :vehicle_type, :string
    add_reference :tickets, :seat, foreign_key: true
    add_column :tickets, :price, :decimal, precision: 10, scale: 2
    add_column :tickets, :status, :string, default: 'pending'
    add_column :tickets, :departure_time, :datetime
    add_column :tickets, :arrival_time, :datetime

    add_index :tickets, [:vehicle_id, :vehicle_type]
    add_index :tickets, :status
  end
end
