class RailwayStationNew < Station
  # STI type: 'RailwayStation'
  # This inherits all functionality from Station

  def self.sti_name
    'RailwayStation'
  end
end
