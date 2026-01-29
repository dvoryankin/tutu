class Station < ApplicationRecord
  has_many :stations_routes, dependent: :destroy
  has_many :routes, through: :stations_routes
  has_many :vehicles, foreign_key: :current_station_id

  validates :title, presence: true
  validates :type, presence: true

  scope :ordered, -> { select('stations.*, stations_routes.position').joins(:stations_routes).order("stations_routes.position").distinct }
  scope :by_city, ->(city) { where(city: city) if city.present? }
  scope :by_type, ->(type) { where(type: type) if type.present? }

  def self.inherited(base)
    super
    def base.model_name
      superclass.model_name
    end
  end

  def update_position(route, position)
    station = route_station(route)
    station.update(position: position) if station
  end

  def position_in(route)
    route_station(route).try(:position)
  end

  def update_time(route, arrival, departure)
    station = route_station(route)
    station.update(arrival: arrival, departure: departure) if station
  end

  def time(route, time_type)
    route_station(route).try(time_type)
  end

  def display_name
    city.present? ? "#{title} (#{city})" : title
  end

  private

  def route_station(route)
    @route_station ||= stations_routes.where(route_id: route).first
  end
end
