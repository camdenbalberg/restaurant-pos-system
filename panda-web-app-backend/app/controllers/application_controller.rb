class ApplicationController < ActionController::Base
  Rails.logger.info "Rails Environment: #{Rails.env}"

  before_action :authenticate_user, :force_session
  # include JWTSessions::RailsAuthorization
  # rescue_from JWTSessions::Errors::Unauthorized, with :not_authorized
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Might need to uncomment

  def authenticate_user
    token = cookies[:auth_token]
    if token
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')[0]
      @current_user = User.find(decoded['user_id'])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  # Maybe for future??
# def authenticate_user
#     token = cookies[:auth_token]
#     if token
#       begin
#         decoded = JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256')[0]
#         @current_user = User.find(decoded['user_id'])
#       rescue JWT::DecodeError
#         render json: { error: 'Invalid token' }, status: :unauthorized
#       end
#     else
#       render json: { error: 'Unauthorized' }, status: :unauthorized
#     end
#   end

  private

    def current_user
      @current_user ||= User.find(payload['user_id'])
    end

    def not_authorized
      render json: { error: "Not authorized" }, status: :unauthorized
    end

    def force_session
     # Ensure session data is persisted
     session[:force_persist] = true
     Rails.logger.info "Session ID: #{request.session.id}, Session Data: #{session.to_hash}"
   end
end
