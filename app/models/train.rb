class Train < Vehicle
  # STI type: 'Train' - inherits from Vehicle
  # Maintains backwards compatibility with existing code

  # Legacy associations for backwards compatibility
  has_many :carriages, foreign_key: :train_id

  def transport_type
    'train'
  end

  def display_name
    "Train #{number}"
  end

  # Legacy methods for backwards compatibility
  def count_seats_by_type(type_carriage, type_seat)
    carriages.where(type: type_carriage).sum(type_seat)
  end

  def count_carriages_by_type(type_carriage)
    carriages.where(type: type_carriage).count
  end
end
