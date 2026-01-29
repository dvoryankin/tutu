class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :train, optional: true
  belongs_to :vehicle, polymorphic: true, optional: true
  belongs_to :seat, optional: true
  belongs_to :start_station, class_name: 'RailwayStation', foreign_key: :start_station_id, optional: true
  belongs_to :end_station, class_name: 'RailwayStation', foreign_key: :end_station_id, optional: true

  has_one :cart_item, dependent: :destroy
  has_one :order_item, dependent: :destroy
  has_one :order, through: :order_item

  validates :passenger_name, :passenger_passport, presence: true
  validates :status, inclusion: { in: %w[pending confirmed cancelled refunded] }, allow_nil: true

  after_create :notify_buy
  after_destroy :notify_cancellation_buy

  scope :pending, -> { where(status: 'pending') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :for_user, ->(user) { where(user: user) }
  scope :upcoming, -> { where('departure_time > ?', Time.current).order(:departure_time) }
  scope :past, -> { where('departure_time <= ?', Time.current).order(departure_time: :desc) }

  def route_name
    if start_station && end_station
      "#{start_station.title} - #{end_station.title}"
    else
      vehicle&.route&.name || 'Unknown route'
    end
  end

  def transport_vehicle
    vehicle || train
  end

  def confirmed?
    status == 'confirmed'
  end

  def pending?
    status == 'pending' || status.nil?
  end

  def cancel!
    seat&.release!
    update!(status: 'cancelled')
  end

  def confirm!
    update!(status: 'confirmed')
  end

  private

  def notify_buy
    TicketsMailer.buy_ticket(self.user, self).deliver_now if user.present?
  end

  def notify_cancellation_buy
    TicketsMailer.cancellation_buy_ticket(self.user, self).deliver_now if user.present?
  end
end
