class Search
  include ActiveModel::Model

  attr_accessor :start_station, :end_station
  attr_accessor :start_station_id, :end_station_id
  attr_accessor :transport_type, :date
  attr_accessor :result, :trains_result, :planes_result, :buses_result

  TRANSPORT_TYPES = %w[all train plane bus].freeze

  def self.do(params = {})
    search = Search.new(
      start_station_id: params[:start_station_id],
      end_station_id: params[:end_station_id],
      transport_type: params[:transport_type] || 'all',
      date: params[:date]
    )
    search.perform_search
    search
  end

  def perform_search
    find_stations
    return unless start_station && end_station

    case transport_type
    when 'train'
      @result = search_trains
    when 'plane'
      @result = search_planes
    when 'bus'
      @result = search_buses
    else
      @trains_result = search_trains
      @planes_result = search_planes
      @buses_result = search_buses
      @result = @trains_result + @planes_result + @buses_result
    end
  end

  def search_trains
    trains_by_route_station(start_station) & trains_by_route_station(end_station)
  end

  def search_planes
    vehicles_by_stations(start_station, end_station, 'Plane')
  end

  def search_buses
    vehicles_by_stations(start_station, end_station, 'Bus')
  end

  def trains_by_route_station(station)
    if station.is_a?(RailwayStation)
      Train.includes(route: :railway_stations).where(railway_stations: { id: station.id })
    else
      Vehicle.where(type: 'Train').includes(route: :stations).where(stations: { id: station.id })
    end
  end

  def vehicles_by_stations(start_station, end_station, vehicle_type)
    start_vehicles = Vehicle.where(type: vehicle_type)
                            .joins(route: :stations_routes)
                            .where(stations_routes: { station_id: start_station.id })

    end_vehicles = Vehicle.where(type: vehicle_type)
                          .joins(route: :stations_routes)
                          .where(stations_routes: { station_id: end_station.id })

    start_vehicles & end_vehicles
  end

  def has_results?
    result.present? && result.any?
  end

  def grouped_results
    {
      trains: trains_result || [],
      planes: planes_result || [],
      buses: buses_result || []
    }
  end

  private

  def find_stations
    return if start_station_id.blank? || end_station_id.blank?

    @start_station = find_station(start_station_id)
    @end_station = find_station(end_station_id)
  end

  def find_station(station_id)
    RailwayStation.find_by(id: station_id) ||
      Station.find_by(id: station_id)
  end
end
