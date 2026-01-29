class TrainCompartment < Compartment
  # Train-specific compartment (carriage)
  # class_type can be: economy, coupe, lux, sitting

  SEAT_LAYOUTS = {
    'coupe' => { rows: 9, seats_per_row: 4, types: %w[top bottom top bottom] },
    'economy' => { rows: 9, seats_per_row: 6, types: %w[top bottom side_top side_bottom top bottom] },
    'lux' => { rows: 9, seats_per_row: 2, types: %w[bottom bottom] },
    'sitting' => { rows: 20, seats_per_row: 4, types: %w[window aisle aisle window] }
  }.freeze

  def generate_seats!
    layout = SEAT_LAYOUTS[class_type] || SEAT_LAYOUTS['economy']
    seat_number = 1

    layout[:rows].times do |row|
      layout[:seats_per_row].times do |pos|
        seats.create!(
          seat_number: seat_number.to_s,
          seat_type: layout[:types][pos],
          row: row + 1,
          position: (pos + 1).to_s,
          available: true,
          price_modifier: price_modifier_for_type(layout[:types][pos])
        )
        seat_number += 1
      end
    end

    update!(total_seats: seats.count)
  end

  private

  def price_modifier_for_type(seat_type)
    case seat_type
    when 'bottom' then 1.1
    when 'top' then 0.9
    when 'side_bottom' then 0.85
    when 'side_top' then 0.8
    when 'window' then 1.05
    else 1.0
    end
  end
end
