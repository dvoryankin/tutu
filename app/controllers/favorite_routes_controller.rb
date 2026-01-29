class FavoriteRoutesController < ApplicationController
  before_action :authenticate_user!

  def index
    @favorites = current_user.favorite_routes.includes(:route)
  end

  def create
    @favorite = current_user.favorite_routes.build(favorite_params)

    if @favorite.save
      respond_to do |format|
        format.html { redirect_back fallback_location: favorite_routes_path, notice: 'Route added to favorites' }
        format.json { render json: { success: true, id: @favorite.id } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: search_path, alert: @favorite.errors.full_messages.join(', ') }
        format.json { render json: { success: false, errors: @favorite.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @favorite = current_user.favorite_routes.find(params[:id])
    @favorite.destroy

    respond_to do |format|
      format.html { redirect_to favorite_routes_path, notice: 'Route removed from favorites' }
      format.json { render json: { success: true } }
    end
  end

  private

  def favorite_params
    params.permit(:route_id, :transport_type)
  end
end
