class Api::V1::CartsController < Api::V1::BaseController
  before_action :set_cart

  def show
    render json: {
      success: true,
      cart: {
        id: @cart.id,
        status: @cart.status,
        items_count: @cart.items_count,
        total_amount: @cart.total_amount,
        items: serialize_cart_items
      }
    }
  end

  def add_item
    seat = Seat.find(params[:seat_id])
    vehicle = seat.compartment.vehicle

    reservation = SeatReservation.new(
      seat: seat,
      user: current_user,
      vehicle: vehicle,
      passenger_data: passenger_params
    )

    if reservation.reserve!
      render json: {
        success: true,
        ticket_id: reservation.ticket.id,
        cart: {
          items_count: @cart.items_count,
          total_amount: @cart.total_amount
        }
      }
    else
      render_error(reservation.errors)
    end
  end

  def remove_item
    cart_item = @cart.cart_items.find_by(ticket_id: params[:ticket_id])

    if cart_item
      cart_item.ticket.seat&.release!
      cart_item.ticket.destroy
      cart_item.destroy

      render json: {
        success: true,
        cart: {
          items_count: @cart.items_count,
          total_amount: @cart.total_amount
        }
      }
    else
      render_error('Item not found in cart', status: :not_found)
    end
  end

  def checkout
    if @cart.empty?
      render_error('Cart is empty')
      return
    end

    order = Order.new(user: current_user)
    @cart.cart_items.each do |item|
      order.order_items.build(ticket: item.ticket, price: item.price)
    end

    if order.save
      @cart.checkout!
      render json: {
        success: true,
        order: {
          id: order.id,
          order_number: order.order_number,
          total_amount: order.total_amount
        }
      }
    else
      render_error(order.errors.full_messages)
    end
  end

  private

  def set_cart
    @cart = current_user.current_cart
  end

  def passenger_params
    params.permit(:passenger_name, :passenger_passport, :departure_time, :arrival_time)
  end

  def serialize_cart_items
    @cart.cart_items.includes(ticket: [:seat, vehicle: :route]).map do |item|
      {
        id: item.id,
        ticket_id: item.ticket.id,
        price: item.price,
        vehicle: item.ticket.vehicle&.display_name,
        route: item.ticket.vehicle&.route&.name,
        seat: item.ticket.seat&.full_seat_number
      }
    end
  end
end
