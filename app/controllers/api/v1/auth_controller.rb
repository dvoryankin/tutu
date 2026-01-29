class Api::V1::AuthController < ActionController::API
  def login
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      token = user.generate_api_token!(
        name: params[:token_name] || 'API Token',
        expires_in: 30.days
      )

      render json: {
        success: true,
        token: token.token,
        expires_at: token.expires_at,
        user: {
          id: user.id,
          email: user.email,
          name: user.full_name
        }
      }
    else
      render json: { success: false, error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def logout
    authenticate_with_http_token do |token, _options|
      api_token = ApiToken.find_by(token: token)
      api_token&.destroy
    end

    render json: { success: true, message: 'Logged out successfully' }
  end

  def refresh
    authenticate_with_http_token do |token, _options|
      api_token = ApiToken.find_by(token: token)

      if api_token&.active?
        new_token = api_token.user.generate_api_token!(
          name: api_token.name,
          expires_in: 30.days
        )
        api_token.destroy

        render json: {
          success: true,
          token: new_token.token,
          expires_at: new_token.expires_at
        }
      else
        render json: { success: false, error: 'Invalid or expired token' }, status: :unauthorized
      end
    end
  end
end
