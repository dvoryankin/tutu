class AddIndexesToCarriages < ActiveRecord::Migration[7.0]
  def change
    add_index :carriages, [:id, :type]
  end
end
