class AddPassportToTickets < ActiveRecord::Migration[7.0]
  def change
    add_column :tickets, :passenger_name, :string
    add_column :tickets, :passenger_passport, :string
  end
end
