class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @upcoming_trips_count = current_user.upcoming_trips.count
    @past_trips_count = current_user.past_trips.count
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      redirect_to profile_path, notice: 'Profile updated successfully'
    else
      render :edit
    end
  end

  def trips
    @trips = current_user.tickets.confirmed.past.includes(:vehicle, :seat)
  end

  def upcoming
    @trips = current_user.tickets.confirmed.upcoming.includes(:vehicle, :seat)
  end

  private

  def profile_params
    params.require(:user).permit(:name, :last_name, :phone, :passport_number, :passport_expiry, :date_of_birth)
  end
end
