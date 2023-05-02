class AddOrderCarriagesToTrain < ActiveRecord::Migration[7.0]
  def change
    add_column :trains, :order_carriages, :boolean, default: true
  end
end
