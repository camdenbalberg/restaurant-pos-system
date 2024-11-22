class Api::V1::RecipesController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy]

  # skip_before_action :verify_authenticity_token, only: [:add_recipe]
  # Query database for items and rendering it as json
  def index
    begin
      @recipes = Recipe.joins(:menu_item, :inventory_item)
                      .select('recipes.*, menu_items.menu_name, inventory_items.inv_name')
      render json: @recipes
    rescue => e
      Rails.logger.error "Error in recipes#index: #{e.message}"
      render json: { error: 'Error fetching recipes', details: e.message }, status: :internal_server_error
    end
  end

  def show
    @recipe = Recipe.joins(:menu_item, :inventory_item)
                   .select('recipes.*, menu_items.menu_name, inventory_items.inv_name')
                   .find_by(menu_id: params[:id])
    render json: @recipe
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recipe not found" }, status: :not_found
  end

  def create
    recipe = Recipe.new(
      menu_id: params[:menu_id],
      inv_id: params[:inv_id],
      quantity: params[:quantity]
    )

    if recipe.save
      render json: recipe, status: :created
    else
      render json: { error: 'Failed to create recipe' }, status: :unprocessable_entity
    end
  end

  def update
    @recipe = Recipe.find_by(menu_id: params[:menu_id], inv_id: params[:inv_id])
    
    if @recipe.update(recipe_params)
      render json: @recipe, status: :ok
    else
      render json: { error: 'Failed to update recipe' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recipe not found" }, status: :not_found
  end

  def destroy
    @recipe = Recipe.find_by(menu_id: params[:menu_id], inv_id: params[:inv_id])
    
    if @recipe.destroy
      render json: { success: 'Recipe deleted' }, status: :ok
    else
      render json: { error: 'Failed to delete recipe' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recipe not found" }, status: :not_found
  end

  private

  def recipe_params
    params.permit(:menu_id, :inv_id, :quantity)
  end
end