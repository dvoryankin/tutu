class Admin::StationsController < Admin::BaseController
  before_action :set_station, only: [:show, :edit, :update, :destroy, :update_position, :update_time]

  def index
    @stations = Station.order(:type, :title)
    @stations = @stations.where(type: params[:type]) if params[:type].present?
  end

  def show
    @routes = @station.routes
  end

  def new
    @station = Station.new
    @station.type = params[:type] if params[:type].present?
  end

  def create
    @station = Station.new(station_params)

    if @station.save
      redirect_to admin_station_path(@station), notice: 'Station created successfully'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @station.update(station_params)
      redirect_to admin_station_path(@station), notice: 'Station updated successfully'
    else
      render :edit
    end
  end

  def destroy
    @station.destroy
    redirect_to admin_stations_path, notice: 'Station deleted successfully'
  end

  def update_position
    route = Route.find(params[:route_id])
    @station.update_position(route, params[:position].to_i)
    redirect_back fallback_location: admin_station_path(@station), notice: 'Position updated'
  end

  def update_time
    route = Route.find(params[:route_id])
    @station.update_time(route, params[:arrival], params[:departure])
    redirect_back fallback_location: admin_station_path(@station), notice: 'Time updated'
  end

  private

  def set_station
    @station = Station.find(params[:id])
  end

  def station_params
    params.require(:station).permit(:title, :type, :city, :code)
  end
end
