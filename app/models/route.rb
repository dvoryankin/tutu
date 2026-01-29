class Route < ApplicationRecord
  # Legacy associations
  has_many :railway_stations_routes
  has_many :railway_stations, through: :railway_stations_routes

  # New unified associations
  has_many :stations_routes, dependent: :destroy
  has_many :stations, through: :stations_routes

  # Vehicle associations
  has_many :trains
  has_many :vehicles

  has_many :favorite_routes, dependent: :destroy

  validates :name, presence: true
  validate :stations_count

  before_validation :set_name

  scope :with_transport_type, ->(type) {
    joins(:vehicles).where(vehicles: { type: type }).distinct if type.present?
  }

  def start_station
    stations_routes.ordered.first&.station || railway_stations.first
  end

  def end_station
    stations_routes.ordered.last&.station || railway_stations.last
  end

  def all_stations
    if stations_routes.any?
      stations_routes.ordered.includes(:station).map(&:station)
    else
      railway_stations_routes.order(:position).includes(:railway_station).map(&:railway_station)
    end
  end

  private

  def set_name
    if self.name.blank?
      first_station = stations.first || railway_stations.first
      last_station = stations.last || railway_stations.last
      if first_station && last_station
        self.name = "#{first_station.title} - #{last_station.title}"
      end
    end
  end

  def stations_count
    total = stations.size + railway_stations.size
    if total < 2
      errors.add(:base, "Route should contain at least 2 stations")
    end
  end
end
