class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [:show]

  def index
    orders = current_user.orders.recent.includes(:order_items)

    render json: {
      success: true,
      orders: orders.map { |order| serialize_order(order) }
    }
  end

  def show
    render json: {
      success: true,
      order: serialize_order(@order, include_items: true)
    }
  end

  def create
    order = current_user.orders.find_by(id: params[:order_id])

    unless order
      render_error('Order not found', status: :not_found)
      return
    end

    processor = PaymentProcessor.new(
      order: order,
      payment_method: params[:payment_method],
      payment_data: payment_params
    )

    if processor.process!
      render json: {
        success: true,
        order: serialize_order(order.reload, include_items: true),
        transaction_id: processor.transaction_id
      }
    else
      render_error(processor.errors)
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def payment_params
    params.permit(:card_number, :card_expiry, :card_cvv, :cardholder_name)
  end

  def serialize_order(order, include_items: false)
    data = {
      id: order.id,
      order_number: order.order_number,
      status: order.status,
      total_amount: order.total_amount,
      payment_method: order.payment_method,
      paid_at: order.paid_at,
      created_at: order.created_at
    }

    if include_items
      data[:items] = order.order_items.includes(ticket: [:seat, vehicle: :route]).map do |item|
        {
          id: item.id,
          price: item.price,
          ticket: {
            id: item.ticket.id,
            passenger_name: item.ticket.passenger_name,
            vehicle: item.ticket.vehicle&.display_name,
            route: item.ticket.vehicle&.route&.name,
            seat: item.ticket.seat&.full_seat_number,
            status: item.ticket.status
          }
        }
      end
    end

    data
  end
end
