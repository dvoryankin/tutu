class CartCleanupJob < ApplicationJob
  queue_as :low

  # Clean up abandoned carts older than 30 minutes
  ABANDONMENT_THRESHOLD = 30.minutes

  def perform
    abandoned_carts = Cart.active
                          .where('updated_at < ?', ABANDONMENT_THRESHOLD.ago)

    abandoned_carts.find_each do |cart|
      cleanup_cart(cart)
    end

    Rails.logger.info "CartCleanupJob: Cleaned up #{abandoned_carts.count} abandoned carts"
  end

  private

  def cleanup_cart(cart)
    Cart.transaction do
      # Release all reserved seats
      cart.tickets.each do |ticket|
        ticket.seat&.release!
        ticket.destroy
      end

      # Mark cart as abandoned
      cart.abandon!
    end
  rescue StandardError => e
    Rails.logger.error "Failed to cleanup cart #{cart.id}: #{e.message}"
  end
end
