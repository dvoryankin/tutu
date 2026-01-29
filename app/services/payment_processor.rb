class PaymentProcessor
  attr_reader :order, :payment_method, :payment_data, :errors, :transaction_id

  PAYMENT_METHODS = %w[card bank_transfer cash].freeze

  def initialize(order:, payment_method:, payment_data: {})
    @order = order
    @payment_method = payment_method
    @payment_data = payment_data
    @errors = []
  end

  def process!
    return failure('Order not found') unless order
    return failure('Order already paid') if order.paid?
    return failure('Invalid payment method') unless valid_payment_method?
    return failure('Order is empty') if order.order_items.empty?

    begin
      # Mock payment processing
      process_payment

      if payment_successful?
        complete_payment!
        success
      else
        fail_payment!
        failure('Payment declined')
      end
    rescue StandardError => e
      fail_payment!
      failure("Payment error: #{e.message}")
    end
  end

  def success?
    errors.empty?
  end

  private

  def valid_payment_method?
    PAYMENT_METHODS.include?(payment_method)
  end

  def process_payment
    # Mock payment processing - in real app would integrate with payment gateway
    @transaction_id = generate_transaction_id

    case payment_method
    when 'card'
      process_card_payment
    when 'bank_transfer'
      process_bank_transfer
    when 'cash'
      process_cash_payment
    end
  end

  def process_card_payment
    # Mock card validation
    card_number = payment_data[:card_number]
    return unless card_number

    # Simulate successful payment for valid test cards
    @payment_successful = card_number.to_s.length >= 16
  end

  def process_bank_transfer
    # Bank transfers are always "pending" until confirmed
    @payment_successful = true
  end

  def process_cash_payment
    # Cash payments are confirmed on delivery
    @payment_successful = true
  end

  def payment_successful?
    @payment_successful
  end

  def complete_payment!
    order.pay!(payment_method: payment_method)
    send_confirmation_email
  end

  def fail_payment!
    order.fail!
    send_failure_email
  end

  def send_confirmation_email
    OrdersMailer.order_confirmed(order).deliver_later if defined?(OrdersMailer)
  end

  def send_failure_email
    OrdersMailer.payment_failed(order).deliver_later if defined?(OrdersMailer)
  end

  def generate_transaction_id
    "TXN-#{Time.current.strftime('%Y%m%d%H%M%S')}-#{SecureRandom.hex(4).upcase}"
  end

  def success
    true
  end

  def failure(message)
    @errors << message
    false
  end
end
