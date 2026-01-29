class FavoriteRoute < ApplicationRecord
  belongs_to :user
  belongs_to :route

  validates :route_id, uniqueness: { scope: :user_id, message: 'already in favorites' }
  validates :transport_type, inclusion: { in: %w[train plane bus all] }, allow_nil: true

  scope :by_transport, ->(type) { where(transport_type: type) if type.present? }
end
