class TicketsMailer < ApplicationMailer
  def buy_ticket(user, ticket)
    @user = user
    @ticket = ticket
    mail(to: user.email, subject: t('.subject', default: 'Your ticket purchase confirmation'))
  end

  def cancellation_buy_ticket(user, ticket)
    @user = user
    @ticket = ticket
    mail(to: user.email, subject: t('.subject', default: 'Your ticket has been cancelled'))
  end

  def trip_reminder(user, ticket)
    @user = user
    @ticket = ticket
    @departure_time = ticket.departure_time
    mail(to: user.email, subject: t('.subject', default: 'Reminder: Your trip is tomorrow'))
  end
end
