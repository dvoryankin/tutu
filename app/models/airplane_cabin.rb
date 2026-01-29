class AirplaneCabin < Compartment
  # Airplane cabin compartment
  # class_type can be: economy, business, first

  SEAT_LAYOUTS = {
    'economy' => { rows: 30, seats_per_row: 6, positions: %w[A B C D E F], types: %w[window middle aisle aisle middle window] },
    'business' => { rows: 10, seats_per_row: 4, positions: %w[A B C D], types: %w[window aisle aisle window] },
    'first' => { rows: 4, seats_per_row: 2, positions: %w[A B], types: %w[window window] }
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
    when 'window' then 1.1
    when 'aisle' then 1.05
    else 1.0
    end
  end
end
