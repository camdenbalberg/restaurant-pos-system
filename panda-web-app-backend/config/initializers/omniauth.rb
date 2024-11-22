OmniAuth.config.logger = Rails.logger
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["VITE_GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
           scope: "userinfo.email, userinfo.profile",
           prompt: "select_account"
  OmniAuth.config.logger = Rails.logger
  OmniAuth.config.allowed_request_methods = %i[get post]
  OmniAuth.config.silence_get_warning = true

  # Log OmniAuth state for debugging
  # Force to save omniauth state
  OmniAuth.config.before_request_phase do |env|
    env['rack.session']['omniauth.state'] ||= SecureRandom.hex(24)
    Rails.logger.info "Generated and stored state in session: #{env['rack.session']['omniauth.state']}"
  end

  OmniAuth.config.before_callback_phase do |env|
    Rails.logger.info "OmniAuth Callback Phase: Session state = #{env['rack.session']['omniauth.state']}, Callback state = #{env['QUERY_STRING']}"
  end

  Rails.logger.info "OmniAuth middleware initialized"
end
