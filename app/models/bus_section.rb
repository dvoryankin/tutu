class BusSection < Compartment
  # Bus section compartment
  # class_type can be: economy, business

  SEAT_LAYOUTS = {
    'economy' => { rows: 12, seats_per_row: 4, positions: %w[A B C D], types: %w[window aisle aisle window] },
    'business' => { rows: 8, seats_per_row: 3, positions: %w[A B C], types: %w[window aisle window] }
  }.freeze

  def generate_seats!
    layout = SEAT_LAYOUTS[class_type] || SEAT_LAYOUTS['economy']

    layout[:rows].times do |row|
      row_number = row + 1
      layout[:seats_per_row].times do |pos|
        seats.create!(
          seat_number: "#{row_number}#{layout[:positions][pos]}",
          seat_type: layout[:types][pos],
          row: row_number,
          position: layout[:positions][pos],
          available: true,
          price_modifier: price_modifier_for_type(layout[:types][pos])
        )
      end
    end

    update!(total_seats: seats.count)
  end

  private

  def price_modifier_for_type(seat_type)
    case seat_type
    when 'window' then 1.05
    else 1.0
    end
  end
end
