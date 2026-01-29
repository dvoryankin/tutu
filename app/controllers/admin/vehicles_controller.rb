class Admin::VehiclesController < Admin::BaseController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy]

  def index
    @vehicles = Vehicle.includes(:route, :current_station).order(:type, :number)
    @vehicles = @vehicles.where(type: params[:type]) if params[:type].present?
  end

  def show
    @compartments = @vehicle.compartments.ordered
  end

  def new
    @vehicle = Vehicle.new
    @vehicle.type = params[:type] if params[:type].present?
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)

    if @vehicle.save
      redirect_to admin_vehicle_path(@vehicle), notice: 'Vehicle created successfully'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      redirect_to admin_vehicle_path(@vehicle), notice: 'Vehicle updated successfully'
    else
      render :edit
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to admin_vehicles_path, notice: 'Vehicle deleted successfully'
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:number, :type, :route_id, :current_station_id)
  end
end
