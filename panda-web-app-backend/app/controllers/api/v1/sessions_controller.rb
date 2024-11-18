require "net/http"
require "json"

class Api::V1::SessionsController < ApplicationController
  def omniauth
    user_info = request.env["omniauth.auth"]
    user = User.find_or_create_by(email: user_info["info"]["email"]) do |user|
      user.name = user_info["info"]["name"]
      user.image = user_info["info"]["image"]
    end

    if user
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: { id: user.id, name: user.name, email: user.email, image: user.image } }, status: :ok
    else
      render json: { error: "Authentication failed" }, status: :unauthorized
    end
  end

  def failure
    render json: { error: "Authentication failed" }, status: :unauthorized
  end
end
