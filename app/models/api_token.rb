class ApiToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  scope :active, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def active?
    !expired?
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  def self.authenticate(token_string)
    token = active.find_by(token: token_string)
    if token
      token.touch_last_used!
      token.user
    end
  end

  private

  def generate_token
    self.token ||= SecureRandom.hex(32)
  end
end
