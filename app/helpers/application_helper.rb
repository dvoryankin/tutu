module ApplicationHelper
  def vehicle_badge_color(vehicle)
    case vehicle.class.name
    when 'Train' then 'primary'
    when 'Plane' then 'info'
    when 'Bus' then 'success'
    else 'secondary'
    end
  end

  def station_badge_color(station)
    case station.class.name
    when 'RailwayStation' then 'primary'
    when 'Airport' then 'info'
    when 'BusStation' then 'success'
    else 'secondary'
    end
  end

  def transport_badge_color(transport_type)
    case transport_type.to_s
    when 'train' then 'primary'
    when 'plane' then 'info'
    when 'bus' then 'success'
    else 'secondary'
    end
  end

  def order_status_color(status)
    case status.to_s
    when 'pending' then 'warning'
    when 'paid' then 'success'
    when 'failed' then 'danger'
    when 'refunded' then 'secondary'
    else 'secondary'
    end
  end

  def ticket_status_color(status)
    case status.to_s
    when 'pending' then 'warning'
    when 'confirmed' then 'success'
    when 'cancelled' then 'danger'
    when 'refunded' then 'secondary'
    else 'secondary'
    end
  end
end
