class Compartment < ApplicationRecord
  belongs_to :vehicle
  has_many :seats, dependent: :destroy

  validates :number, uniqueness: { scope: :vehicle_id, message: 'already exists for this vehicle' }
  validates :class_type, inclusion: { in: %w[economy business first coupe lux sitting] }

  before_validation :add_number

  scope :by_class, ->(class_type) { where(class_type: class_type) if class_type.present? }
  scope :ordered, ->(asc = true) { order(number: asc ? :asc : :desc) }

  def self.inherited(base)
    super
    def base.model_name
      superclass.model_name
    end
  end

  def available_seats_count
    seats.where(available: true).count
  end

  def base_price_for_class
    case class_type
    when 'first' then base_price * 2.5
    when 'business' then base_price * 1.8
    when 'lux' then base_price * 3.0
    when 'coupe' then base_price * 1.5
    else base_price
    end
  end

  private

  def add_number
    if vehicle && number.blank?
      max_number = Compartment.where(vehicle: vehicle).maximum(:number)
      self.number = max_number.nil? ? '1' : (max_number.to_i + 1).to_s
    end
  end
end
