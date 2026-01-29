class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :tickets, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :favorite_routes, dependent: :destroy
  has_many :api_tokens, dependent: :destroy

  def current_cart
    carts.active.first_or_create
  end

  def upcoming_trips
    tickets.confirmed.upcoming
  end

  def past_trips
    tickets.confirmed.past
  end

  def full_name
    [name, last_name].compact.join(' ').presence || email
  end

  def generate_api_token!(name: nil, expires_in: nil)
    api_tokens.create!(
      name: name,
      expires_at: expires_in ? Time.current + expires_in : nil
    )
  end
end
