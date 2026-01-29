class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :tickets, through: :cart_items

  validates :status, inclusion: { in: %w[active checked_out abandoned] }

  scope :active, -> { where(status: 'active') }
  scope :abandoned, -> { where(status: 'abandoned') }
  scope :stale, -> { where('updated_at < ?', 30.minutes.ago) }

  def total_amount
    cart_items.sum(:price)
  end

  def items_count
    cart_items.count
  end

  def add_ticket(ticket, price)
    cart_items.find_or_create_by(ticket: ticket) do |item|
      item.price = price
    end
  end

  def remove_ticket(ticket)
    cart_items.find_by(ticket: ticket)&.destroy
  end

  def checkout!
    update!(status: 'checked_out')
  end

  def abandon!
    update!(status: 'abandoned')
    release_all_seats!
  end

  def empty?
    cart_items.empty?
  end

  def clear!
    release_all_seats!
    cart_items.destroy_all
  end

  private

  def release_all_seats!
    tickets.each do |ticket|
      ticket.seat&.release!
    end
  end
end
