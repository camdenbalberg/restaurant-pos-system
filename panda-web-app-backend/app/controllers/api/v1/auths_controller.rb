class Api::V1::AuthsController < ApplicationController
  skip_before_action :authenticate_user, only: [:validate_token]

  def validate_token
    Rails.logger.info "Cookies received: #{request.cookies.inspect}" # Log all cookies
    token = cookies[:auth_token]
    if token
      Rails.logger.info "auth_token received: #{token}" # Log the token value
      begin
        Rails.logger.info "[AUTH CONTROL] Current Environment: #{Rails.env}"
        Rails.logger.info "[AUTH CONTROL] Secret Key Base Used for Decoding: #{Rails.application.credentials.secret_key_base}"
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')[0]
        user = User.find(decoded['user_id'])
        render json: { valid: true, user: { id: user.id, name: user.name, avatar_url: user.avatar_url, role: user.role } }, status: :ok
      rescue JWT::DecodeError => e
        Rails.logger.error "JWT decode error: #{e.message}" # Log decoding errors
        render json: { valid: false, error: 'Invalid token' }, status: :unauthorized
      end
    else
      Rails.logger.warn "No auth_token provided in cookies" # Log missing token
      render json: { valid: false, error: 'No token provided' }, status: :unauthorized
    end
  end
end
