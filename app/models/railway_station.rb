class RailwayStation < ApplicationRecord
  #has_and_belongs_to_many :routes
  has_many :trains, foreign_key: :current_station_id
  has_many :railway_stations_routes
  has_many :routes, through: :railway_stations_routes

  validates :title, presence: true

  scope :ordered, -> { order('index_station ASC') }
end
