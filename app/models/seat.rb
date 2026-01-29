class Seat < ApplicationRecord
  belongs_to :compartment
  has_one :vehicle, through: :compartment
  has_many :tickets

  validates :seat_number, presence: true
  validates :seat_number, uniqueness: { scope: :compartment_id, message: 'already exists in this compartment' }

  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where(available: false) }
  scope :by_type, ->(type) { where(seat_type: type) if type.present? }
  scope :by_row, ->(row) { where(row: row) if row.present? }

  def reserve!
    update!(available: false)
  end

  def release!
    update!(available: true)
  end

  def price(base_price)
    (base_price * (price_modifier || 1.0)).round(2)
  end

  def display_name
    "Row #{row}, Seat #{seat_number} (#{seat_type})"
  end

  def full_seat_number
    "#{compartment.number}-#{seat_number}"
  end
end
