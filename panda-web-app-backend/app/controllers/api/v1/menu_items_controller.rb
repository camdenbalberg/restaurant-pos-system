class Api::V1::MenuItemsController < ApplicationController

      # Query database for items and rendering it as json
      def index
        if params[:category]
          menu_items = MenuItem.where(category: params[:category])
          render json: menu_items
        else
          render json: MenuItem.all
        end
      end

      # GET /api/v1/menu_items/:id
      def show
        menu_items = MenuItem.find(params[:id])
        render json: menu_items
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Menu item not found' }, status: :not_found
      end

      # POST /api/v1/menu_items/add_menu_item
      def add_menu_item
        menu_name = params[:menuName]
        price = params[:price]
        category = params[:category]
        # recipe = params[:recipe]

          # Check if all required parameters are present
        if menu_name.nil? || price.nil? || category.nil?
          render json: { error: 'Missing parameters: menuName, price, or recipe' }, status: :unprocessable_entity
          return
        end

        # Convert recipe into an array of integers
        # recipe = recipe.split(',').map { |ingredient| ingredient.strip.to_i }

        # Create new MenuItem instance
        menu_item = MenuItem.new(menu_name: menu_name, price: price, category: category)
        if menu_item.save
          render json: menu_item, status: :created
        else
          render json: { error: 'Failed to create menu item' }, status: :unprocessable_entity
        end
      end
end
