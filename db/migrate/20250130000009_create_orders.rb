class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :order_number, null: false
      t.decimal :total_amount, precision: 10, scale: 2, default: 0
      t.string :status, default: 'pending'
      t.string :payment_method
      t.datetime :paid_at

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :status
    add_index :orders, [:user_id, :status]
  end
end
