class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :ticket

  validates :ticket_id, uniqueness: { scope: :order_id, message: 'already in order' }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  after_save :update_order_total
  after_destroy :update_order_total

  private

  def update_order_total
    order.recalculate_total!
  end
end
