class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show]

  def index
    @orders = current_user.orders.recent.includes(:order_items, :tickets)
  end

  def show
    @order_items = @order.order_items.includes(ticket: [:seat, :vehicle])
  end

  def new
    @order = Order.find_by(id: params[:order_id], user: current_user)
    redirect_to orders_path, alert: 'Order not found' unless @order
  end

  def create
    @order = Order.find_by(id: params[:order_id], user: current_user)

    unless @order
      redirect_to orders_path, alert: 'Order not found'
      return
    end

    processor = PaymentProcessor.new(
      order: @order,
      payment_method: params[:payment_method],
      payment_data: payment_params
    )

    if processor.process!
      redirect_to order_path(@order), notice: 'Payment successful! Your tickets are confirmed.'
    else
      redirect_to new_order_path(order_id: @order.id), alert: processor.errors.join(', ')
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def payment_params
    params.permit(:card_number, :card_expiry, :card_cvv, :cardholder_name)
  end
end
