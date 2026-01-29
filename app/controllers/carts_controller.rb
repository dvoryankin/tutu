class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(ticket: [:seat, :vehicle])
  end

  def add_item
    ticket = Ticket.find(params[:ticket_id])

    if @cart.add_ticket(ticket, ticket.price)
      redirect_to cart_path, notice: 'Ticket added to cart'
    else
      redirect_back fallback_location: search_path, alert: 'Could not add ticket to cart'
    end
  end

  def remove_item
    ticket = Ticket.find(params[:ticket_id])

    if @cart.remove_ticket(ticket)
      ticket.seat&.release!
      ticket.destroy
      redirect_to cart_path, notice: 'Ticket removed from cart'
    else
      redirect_to cart_path, alert: 'Could not remove ticket'
    end
  end

  def checkout
    if @cart.empty?
      redirect_to cart_path, alert: 'Cart is empty'
      return
    end

    @order = Order.new(user: current_user)
    @cart.cart_items.each do |item|
      @order.order_items.build(ticket: item.ticket, price: item.price)
    end

    if @order.save
      @cart.checkout!
      redirect_to new_order_path(order_id: @order.id), notice: 'Proceed to payment'
    else
      redirect_to cart_path, alert: 'Could not create order'
    end
  end

  private

  def set_cart
    @cart = current_user.current_cart
  end
end
