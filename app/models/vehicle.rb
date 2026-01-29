class Vehicle < ApplicationRecord
  belongs_to :route, optional: true
  belongs_to :current_station, class_name: 'Station', foreign_key: :current_station_id, optional: true
  has_many :compartments, dependent: :destroy
  has_many :tickets, as: :vehicle

  validates :number, presence: true
  validates :number, uniqueness: { scope: :type, message: 'already exists for this vehicle type' }
  validates :type, presence: true

  scope :by_type, ->(type) { where(type: type) if type.present? }
  scope :on_route, ->(route) { where(route: route) }

  def self.inherited(base)
    super
    def base.model_name
      superclass.model_name
    end
  end

  def transport_type
    self.class.name.underscore
  end

  def total_seats
    compartments.sum(:total_seats)
  end

  def available_seats
    compartments.joins(:seats).where(seats: { available: true }).count
  end

  def display_name
    "#{self.class.name} #{number}"
  end
end
