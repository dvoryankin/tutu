class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :ticket, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end

    add_index :order_items, [:order_id, :ticket_id], unique: true
  end
end
