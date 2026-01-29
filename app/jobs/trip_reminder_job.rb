class TripReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Find tickets with departure in next 24 hours
    upcoming_tickets = Ticket.confirmed
                              .where(departure_time: 24.hours.from_now..25.hours.from_now)
                              .includes(:user, :vehicle)

    upcoming_tickets.find_each do |ticket|
      send_reminder(ticket)
    end
  end

  private

  def send_reminder(ticket)
    return unless ticket.user.present?

    TicketsMailer.trip_reminder(ticket.user, ticket).deliver_later
  rescue StandardError => e
    Rails.logger.error "Failed to send trip reminder for ticket #{ticket.id}: #{e.message}"
  end
end
