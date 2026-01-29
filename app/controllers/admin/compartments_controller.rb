class Admin::CompartmentsController < Admin::BaseController
  before_action :set_vehicle, only: [:index, :new, :create]
  before_action :set_compartment, only: [:show, :edit, :update, :destroy]

  def index
    @compartments = @vehicle.compartments.ordered
  end

  def show
    @seats = @compartment.seats.order(:row, :position)
  end

  def new
    @compartment = @vehicle.compartments.build
    @compartment.type = default_compartment_type
  end

  def create
    @compartment = @vehicle.compartments.build(compartment_params)

    if @compartment.save
      @compartment.generate_seats! if @compartment.respond_to?(:generate_seats!)
      redirect_to admin_compartment_path(@compartment), notice: 'Compartment created successfully'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @compartment.update(compartment_params)
      redirect_to admin_compartment_path(@compartment), notice: 'Compartment updated successfully'
    else
      render :edit
    end
  end

  def destroy
    vehicle = @compartment.vehicle
    @compartment.destroy
    redirect_to admin_vehicle_compartments_path(vehicle), notice: 'Compartment deleted successfully'
  end

  private

  def set_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
  end

  def set_compartment
    @compartment = Compartment.find(params[:id])
  end

  def compartment_params
    params.require(:compartment).permit(:number, :type, :class_type, :total_seats, :base_price)
  end

  def default_compartment_type
    case @vehicle.type
    when 'Train' then 'TrainCompartment'
    when 'Plane' then 'AirplaneCabin'
    when 'Bus' then 'BusSection'
    else 'Compartment'
    end
  end
end
