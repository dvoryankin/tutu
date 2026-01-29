class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :tickets, through: :order_items

  validates :order_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending paid failed refunded] }

  before_validation :generate_order_number, on: :create

  scope :pending, -> { where(status: 'pending') }
  scope :paid, -> { where(status: 'paid') }
  scope :recent, -> { order(created_at: :desc) }

  def pay!(payment_method:)
    update!(
      status: 'paid',
      payment_method: payment_method,
      paid_at: Time.current
    )
    confirm_tickets!
  end

  def fail!
    update!(status: 'failed')
    release_tickets!
  end

  def refund!
    update!(status: 'refunded')
    release_tickets!
  end

  def paid?
    status == 'paid'
  end

  def calculate_total
    order_items.sum(:price)
  end

  def recalculate_total!
    update!(total_amount: calculate_total)
  end

  private

  def generate_order_number
    self.order_number ||= "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def confirm_tickets!
    tickets.update_all(status: 'confirmed')
  end

  def release_tickets!
    tickets.each do |ticket|
      ticket.seat&.release!
      ticket.update!(status: 'cancelled')
    end
  end
end
