class Api::V1::FavoriteRoutesController < Api::V1::BaseController
  def index
    favorites = current_user.favorite_routes.includes(:route)

    render json: {
      success: true,
      favorites: favorites.map { |fav| serialize_favorite(fav) }
    }
  end

  def create
    favorite = current_user.favorite_routes.build(favorite_params)

    if favorite.save
      render json: {
        success: true,
        favorite: serialize_favorite(favorite)
      }, status: :created
    else
      render_error(favorite.errors.full_messages)
    end
  end

  def destroy
    favorite = current_user.favorite_routes.find(params[:id])
    favorite.destroy

    render json: { success: true, message: 'Favorite removed' }
  end

  private

  def favorite_params
    params.permit(:route_id, :transport_type)
  end

  def serialize_favorite(favorite)
    {
      id: favorite.id,
      route: {
        id: favorite.route.id,
        name: favorite.route.name
      },
      transport_type: favorite.transport_type,
      created_at: favorite.created_at
    }
  end
end
