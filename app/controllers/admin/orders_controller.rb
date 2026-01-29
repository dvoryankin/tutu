class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [:show, :update]

  def index
    @orders = Order.includes(:user, :order_items).recent
    @orders = @orders.where(status: params[:status]) if params[:status].present?
  end

  def show
    @order_items = @order.order_items.includes(ticket: [:seat, :vehicle])
  end

  def update
    case params[:action_type]
    when 'refund'
      @order.refund!
      redirect_to admin_order_path(@order), notice: 'Order refunded'
    when 'confirm'
      @order.pay!(payment_method: 'admin_confirmed')
      redirect_to admin_order_path(@order), notice: 'Order confirmed'
    else
      redirect_to admin_order_path(@order), alert: 'Unknown action'
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
