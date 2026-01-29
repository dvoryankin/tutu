class Airport < Station
  validates :code, presence: true, uniqueness: true, length: { is: 3 }

  def display_name
    "#{title} (#{code})"
  end
end
