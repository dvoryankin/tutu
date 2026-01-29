class Admin::StatisticsController < Admin::BaseController
  def index
    @total_users = User.count
    @total_orders = Order.count
    @total_revenue = Order.paid.sum(:total_amount)
    @total_tickets = Ticket.count
    @confirmed_tickets = Ticket.confirmed.count

    @orders_by_status = Order.group(:status).count
    @tickets_by_status = Ticket.group(:status).count

    @recent_orders = Order.recent.limit(10).includes(:user)
    @popular_routes = Route.joins(:vehicles)
                           .group('routes.id')
                           .order('COUNT(vehicles.id) DESC')
                           .limit(10)

    # Monthly statistics
    @monthly_orders = Order.where('created_at >= ?', 12.months.ago)
                           .group("DATE_TRUNC('month', created_at)")
                           .count

    @monthly_revenue = Order.paid
                            .where('created_at >= ?', 12.months.ago)
                            .group("DATE_TRUNC('month', created_at)")
                            .sum(:total_amount)
  end
end
