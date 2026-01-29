class OrdersMailer < ApplicationMailer
  def order_confirmed(order)
    @order = order
    @user = order.user
    @tickets = order.tickets
    mail(to: @user.email, subject: "Order #{order.order_number} confirmed")
  end

  def payment_received(order)
    @order = order
    @user = order.user
    mail(to: @user.email, subject: "Payment received for order #{order.order_number}")
  end

  def payment_failed(order)
    @order = order
    @user = order.user
    mail(to: @user.email, subject: "Payment failed for order #{order.order_number}")
  end
end
