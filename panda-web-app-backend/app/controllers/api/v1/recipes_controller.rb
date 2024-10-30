class Api::V1::RecipesController < ApplicationController
  # Query database for items and rendering it as json
  def index
    @recipes = Recipe.all
    render json: @recipes
  end

  # GET /api/v1/recipe_controller/id
  # retrieve with id
  def show
    @recipe = Recipe.find(params[:id])
    render json: @recipe
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Could not wind recipe with the id" }, status: :not_found
  end
end
