class ProcessPaymentJob < ApplicationJob
  queue_as :default

  def perform(order_id, payment_method, payment_data = {})
    order = Order.find(order_id)

    return if order.paid?

    processor = PaymentProcessor.new(
      order: order,
      payment_method: payment_method,
      payment_data: payment_data
    )

    if processor.process!
      Rails.logger.info "ProcessPaymentJob: Order #{order.order_number} paid successfully"
    else
      Rails.logger.error "ProcessPaymentJob: Order #{order.order_number} payment failed: #{processor.errors.join(', ')}"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "ProcessPaymentJob: Order #{order_id} not found"
  rescue StandardError => e
    Rails.logger.error "ProcessPaymentJob: Error processing order #{order_id}: #{e.message}"
    raise # Re-raise for retry
  end
end
