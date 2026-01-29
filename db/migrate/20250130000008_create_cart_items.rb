class CreateCartItems < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :ticket, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end

    add_index :cart_items, [:cart_id, :ticket_id], unique: true
  end
end
