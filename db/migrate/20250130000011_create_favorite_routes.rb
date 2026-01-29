class CreateFavoriteRoutes < ActiveRecord::Migration[7.0]
  def change
    create_table :favorite_routes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true
      t.string :transport_type

      t.timestamps
    end

    add_index :favorite_routes, [:user_id, :route_id], unique: true
    add_index :favorite_routes, :transport_type
  end
end
