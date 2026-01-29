class AddProfileFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone, :string
    add_column :users, :passport_number, :string
    add_column :users, :passport_expiry, :date
    add_column :users, :date_of_birth, :date
  end
end
