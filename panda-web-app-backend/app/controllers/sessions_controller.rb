class SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: [:google_auth]

  def google_auth
    Rails.logger.info "Session state: #{session['omniauth.state']}"
    Rails.logger.info "Callback state: #{params['state']}"
    Rails.logger.info "Session ID: #{request.session.id}"

    # if session['omniauth.state'] != params['state']
    #   render json: { error: 'State mismatch' }, status: :unprocessable_entity
    #   return
    # end

    user_info = request.env['omniauth.auth']
    user = User.find_or_create_by(email: user_info['info']['email']) do |u|
      u.name = user_info['info']['name']
      u.avatar_url = user_info['info']['image']
    end

    # Expire token after 2 hours
    expire_at = 2.hours.from_now.to_i
    token = JWT.encode({ user_id: user.id, expire: expire_at }, Rails.application.credentials.secret_key_base, 'HS256')
    Rails.logger.info "[SESSIONS CONTROL] Current Environment: #{Rails.env}"
    Rails.logger.info "[SESSIONS CONTROL] Secret Key Base Used for Decoding: #{Rails.application.credentials.secret_key_base}"

    response.set_cookie('auth_token', {
                          value: token,
                          httponly: true,
                          secure: Rails.env.production?,
                          same_site: :strict,
                          path: '/'
                        })

    response.set_cookie('user_info', {
                          value: { name: user.name, avatar_url: user.avatar_url }.to_json,
                          httponly: false,
                          secure: Rails.env.production?,
                          same_site: :strict,
                          path: '/'
                       })

    # render json: { token: token, user: user }
    redirect_to '/'
    # Alternative: Redirect with Query Parameters
    # If you want to pass the token and user information to the frontend during the redirect, you can include them as query parameters:
    # redirect_to "/?token=#{token}&user_id=#{user.id}"
  end
end
