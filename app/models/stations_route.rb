class StationsRoute < ApplicationRecord
  belongs_to :station
  belongs_to :route

  validates :station_id, uniqueness: { scope: :route_id, message: 'already in route' }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position) }

  def formatted_arrival
    arrival&.strftime('%H:%M')
  end

  def formatted_departure
    departure&.strftime('%H:%M')
  end
end
