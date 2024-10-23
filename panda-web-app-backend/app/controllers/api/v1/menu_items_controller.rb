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
end
