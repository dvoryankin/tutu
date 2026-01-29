class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_api_user!

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request

  protected

  def authenticate_api_user!
    authenticate_with_http_token do |token, _options|
      @current_user = ApiToken.authenticate(token)
    end

    render_unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  def bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def render_success(data = {}, status: :ok)
    render json: { success: true, data: data }, status: status
  end

  def render_error(errors, status: :unprocessable_entity)
    render json: { success: false, errors: Array(errors) }, status: status
  end
end
