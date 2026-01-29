class TransportSearch
  attr_reader :params, :results

  def initialize(params = {})
    @params = params
    @results = { trains: [], planes: [], buses: [] }
  end

  def call
    return self unless valid_params?

    search_by_transport_type
    self
  end

  def total_count
    results.values.flatten.count
  end

  def has_results?
    total_count > 0
  end

  def all_results
    results.values.flatten
  end

  private

  def valid_params?
    params[:start_station_id].present? && params[:end_station_id].present?
  end

  def search_by_transport_type
    case params[:transport_type]
    when 'train'
      @results[:trains] = search_trains
    when 'plane'
      @results[:planes] = search_planes
    when 'bus'
      @results[:buses] = search_buses
    else
      @results[:trains] = search_trains
      @results[:planes] = search_planes
      @results[:buses] = search_buses
    end
  end

  def search_trains
    start_trains = Train.joins(route: :stations_routes)
                        .where(stations_routes: { station_id: params[:start_station_id] })

    end_trains = Train.joins(route: :stations_routes)
                      .where(stations_routes: { station_id: params[:end_station_id] })

    result = start_trains & end_trains

    # Also check legacy railway_stations association
    legacy_start = Train.joins(route: :railway_stations_routes)
                        .where(railway_stations_routes: { railway_station_id: params[:start_station_id] })
    legacy_end = Train.joins(route: :railway_stations_routes)
                      .where(railway_stations_routes: { railway_station_id: params[:end_station_id] })

    (result + (legacy_start & legacy_end)).uniq
  end

  def search_planes
    search_vehicles('Plane')
  end

  def search_buses
    search_vehicles('Bus')
  end

  def search_vehicles(vehicle_type)
    start_vehicles = Vehicle.where(type: vehicle_type)
                            .joins(route: :stations_routes)
                            .where(stations_routes: { station_id: params[:start_station_id] })

    end_vehicles = Vehicle.where(type: vehicle_type)
                          .joins(route: :stations_routes)
                          .where(stations_routes: { station_id: params[:end_station_id] })

    start_vehicles & end_vehicles
  end
end
