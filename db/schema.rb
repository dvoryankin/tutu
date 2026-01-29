# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_01_30_000014) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.string "name"
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_api_tokens_on_expires_at"
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "carriages", force: :cascade do |t|
    t.string "number"
    t.integer "bottom_seats"
    t.integer "top_seats"
    t.bigint "train_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.integer "side_top_seats"
    t.integer "side_bottom_seats"
    t.integer "sitting_seats"
    t.index ["id", "type"], name: "index_carriages_on_id_and_type"
    t.index ["train_id"], name: "index_carriages_on_train_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "ticket_id", null: false
    t.decimal "price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "ticket_id"], name: "index_cart_items_on_cart_id_and_ticket_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["ticket_id"], name: "index_cart_items_on_ticket_id"
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_carts_on_status"
    t.index ["user_id", "status"], name: "index_carts_on_user_id_and_status"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "compartments", force: :cascade do |t|
    t.string "number"
    t.string "type"
    t.string "class_type", default: "economy"
    t.bigint "vehicle_id", null: false
    t.integer "total_seats", default: 0
    t.decimal "base_price", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_type"], name: "index_compartments_on_class_type"
    t.index ["type"], name: "index_compartments_on_type"
    t.index ["vehicle_id", "number"], name: "index_compartments_on_vehicle_id_and_number", unique: true
    t.index ["vehicle_id"], name: "index_compartments_on_vehicle_id"
  end

  create_table "favorite_routes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "route_id", null: false
    t.string "transport_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_favorite_routes_on_route_id"
    t.index ["transport_type"], name: "index_favorite_routes_on_transport_type"
    t.index ["user_id", "route_id"], name: "index_favorite_routes_on_user_id_and_route_id", unique: true
    t.index ["user_id"], name: "index_favorite_routes_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "ticket_id", null: false
    t.decimal "price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "ticket_id"], name: "index_order_items_on_order_id_and_ticket_id", unique: true
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["ticket_id"], name: "index_order_items_on_ticket_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "order_number", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.string "status", default: "pending"
    t.string "payment_method"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id", "status"], name: "index_orders_on_user_id_and_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "railway_stations", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "railway_stations_routes", force: :cascade do |t|
    t.integer "railway_station_id"
    t.integer "route_id"
    t.integer "position"
    t.string "arrival"
    t.string "departure"
  end

  create_table "routes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seats", force: :cascade do |t|
    t.bigint "compartment_id", null: false
    t.string "seat_number", null: false
    t.string "seat_type"
    t.integer "row"
    t.string "position"
    t.boolean "available", default: true
    t.decimal "price_modifier", precision: 5, scale: 2, default: "1.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_seats_on_available"
    t.index ["compartment_id", "seat_number"], name: "index_seats_on_compartment_id_and_seat_number", unique: true
    t.index ["compartment_id"], name: "index_seats_on_compartment_id"
    t.index ["seat_type"], name: "index_seats_on_seat_type"
  end

  create_table "stations", force: :cascade do |t|
    t.string "title", null: false
    t.string "type", null: false
    t.string "city"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_stations_on_city"
    t.index ["code"], name: "index_stations_on_code", unique: true, where: "(code IS NOT NULL)"
    t.index ["type"], name: "index_stations_on_type"
  end

  create_table "stations_routes", force: :cascade do |t|
    t.bigint "station_id", null: false
    t.bigint "route_id", null: false
    t.integer "position", default: 0
    t.time "arrival"
    t.time "departure"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id", "position"], name: "index_stations_routes_on_route_id_and_position"
    t.index ["route_id"], name: "index_stations_routes_on_route_id"
    t.index ["station_id", "route_id"], name: "index_stations_routes_on_station_id_and_route_id", unique: true
    t.index ["station_id"], name: "index_stations_routes_on_station_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "train_id"
    t.bigint "start_station_id"
    t.bigint "end_station_id"
    t.string "passenger_name"
    t.string "passenger_passport"
    t.bigint "vehicle_id"
    t.string "vehicle_type"
    t.bigint "seat_id"
    t.decimal "price", precision: 10, scale: 2
    t.string "status", default: "pending"
    t.datetime "departure_time"
    t.datetime "arrival_time"
    t.index ["end_station_id"], name: "index_tickets_on_end_station_id"
    t.index ["seat_id"], name: "index_tickets_on_seat_id"
    t.index ["start_station_id"], name: "index_tickets_on_start_station_id"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["train_id"], name: "index_tickets_on_train_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
    t.index ["vehicle_id", "vehicle_type"], name: "index_tickets_on_vehicle_id_and_vehicle_type"
  end

  create_table "trains", force: :cascade do |t|
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "current_station_id"
    t.bigint "route_id"
    t.boolean "order_carriages", default: true
    t.index ["current_station_id"], name: "index_trains_on_current_station_id"
    t.index ["route_id"], name: "index_trains_on_route_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "admin", default: false
    t.string "last_name"
    t.string "phone"
    t.string "passport_number"
    t.date "passport_expiry"
    t.date "date_of_birth"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "number", null: false
    t.string "type", null: false
    t.bigint "route_id"
    t.bigint "current_station_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_station_id"], name: "index_vehicles_on_current_station_id"
    t.index ["number", "type"], name: "index_vehicles_on_number_and_type", unique: true
    t.index ["route_id"], name: "index_vehicles_on_route_id"
    t.index ["type"], name: "index_vehicles_on_type"
  end

  add_foreign_key "api_tokens", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "tickets"
  add_foreign_key "carts", "users"
  add_foreign_key "compartments", "vehicles"
  add_foreign_key "favorite_routes", "routes"
  add_foreign_key "favorite_routes", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "tickets"
  add_foreign_key "orders", "users"
  add_foreign_key "seats", "compartments"
  add_foreign_key "stations_routes", "routes"
  add_foreign_key "stations_routes", "stations"
  add_foreign_key "tickets", "seats"
  add_foreign_key "vehicles", "routes"
  add_foreign_key "vehicles", "stations", column: "current_station_id"
end
