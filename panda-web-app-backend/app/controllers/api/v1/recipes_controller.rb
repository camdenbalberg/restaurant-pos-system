class Api::V1::RecipesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:add_recipe]
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
    render json: { error: "Could not find recipe with the id" }, status: :not_found
  end

  
  def add_recipe
    menu_id = params[:menu_id]
    inv_id = params[:recipe]
    quantity = params[:quantities]
    
    if menu_id.nil?
      render json: { error: 'Missing parameters: menu_id' }, status: :unprocessable_entity
      return
    end

    if inv_id.nil?
      render json: { error: 'Missing parameters: inv_id' }, status: :unprocessable_entity
      return
    end

    if quantity.nil?
      render json: { error: 'Missing parameters: quantity' }, status: :unprocessable_entity
      return
    end

    inv_id = Array(inv_id).map(&:to_i)#ensure invIds is being treated as a list of ints
    quantity = Array(quantity).map(&:to_i)

    Rails.logger.info "#{inv_id} : #{menu_id}"
    recipes = []

    # Iterate over both arrays simultaneously using zip
    inv_id.zip(quantity).each do |i_id, qty|
      recipe = Recipe.new(menu_id: menu_id, inv_id: i_id, quantity: qty)

      if recipe.save
        recipes << recipe
      else
        # If any recipe fails, return an error and stop
        render json: { error: "Failed to create recipe for inv_id #{i_id}" }, status: :unprocessable_entity
        return
      end
    end
    render json: recipes, status: :created
  end
end
