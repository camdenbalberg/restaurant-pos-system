class Api::V1::RecipesController < ApplicationController


  # GET /api/v1/recipes
  # @description
  # Retrieves all recipes with associated menu item and inventory item information.
  # Joins with menu_items and inventory_items tables to include item names.
  # @returns [Array<Recipe>] List of all recipes with associated data in JSON format
  # @raises [InternalServerError] if database query fails
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

  # GET /api/v1/recipes/:id
  # @description
  # Retrieves recipes for a specific menu item with associated item information.
  # @param id [Integer] The menu_id to find recipes for
  # @returns [Array<Recipe>] List of recipes for the menu item in JSON format
  # @raises ActiveRecord::RecordNotFound if no recipes found
  def show
    @recipe = Recipe.joins(:menu_item, :inventory_item)
                   .select('recipes.*, menu_items.menu_name, inventory_items.inv_name')
                   .where(menu_id: params[:id])
    render json: @recipe
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Recipe not found" }, status: :not_found
  end


  # POST /api/v1/recipes
  # @description
  # Creates a new recipe linking a menu item with an inventory item.
  # @param menu_id [Integer] The ID of the menu item
  # @param inv_id [Integer] The ID of the inventory item
  # @param quantity [Integer] The quantity of the inventory item needed
  # @returns [Recipe] The newly created recipe in JSON format
  # @raises [UnprocessableEntity] if creation fails
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

  # PATCH /api/v1/recipes
  # @description
  # Updates an existing recipe's quantity.
  # @param menu_id [Integer] The ID of the menu item
  # @param inv_id [Integer] The ID of the inventory item
  # @param quantity [Integer] The new quantity needed
  # @returns [Recipe] The updated recipe in JSON format
  # @raises ActiveRecord::RecordNotFound if recipe is not found
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


  # DELETE /api/v1/recipes
  # @description
  # Deletes a recipe linking a menu item and inventory item.
  # @param menu_id [Integer] The ID of the menu item
  # @param inv_id [Integer] The ID of the inventory item
  # @returns [String] Success message in JSON format
  # @raises ActiveRecord::RecordNotFound if recipe is not found
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


  # @description
  # Strong parameters for recipes
  # @returns [ActionController::Parameters] Permitted parameters for recipes
  def recipe_params
    params.permit(:menu_id, :inv_id, :quantity)
  end
end