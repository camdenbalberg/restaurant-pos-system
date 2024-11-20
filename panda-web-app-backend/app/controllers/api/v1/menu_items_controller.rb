class Api::V1::MenuItemsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:add_menu_item, :destroy]
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
        menu_name = params[:menu_name]
        price = params[:price]
        category = params[:category]

          # Check if all required parameters are present
        if menu_name.nil? || price.nil? || category.nil?
          render json: { error: 'Missing parameters: menuName, price, or category' }, status: :unprocessable_entity
          return
        end

        highest_menu_id = MenuItem.maximum(:menu_id) || 0  # Returns 0 if no menu_items exist
        Rails.logger.info "#{highest_menu_id}"
        new_menu_id = highest_menu_id + 1

        Rails.logger.info "Received parameters: menuName = #{menu_name}, price = #{price}, category = #{category}"
        # Create new MenuItem instance
        menu_item = MenuItem.new(menu_id: new_menu_id, menu_name: menu_name, price: price, category: category)
        if menu_item.save
          render json: menu_item, status: :created
        else
          render json: { error: 'Failed to create menu item' }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/menu_items/:menu_id
      def destroy
        menu_item = MenuItem.find_by(menu_id: params[:menu_id])

        if menu_item.nil?
          render json: { error: 'Menu item not found' }, status: :not_found
        else
          menu_item.destroy
          render json: { message: 'Menu item successfully deleted' }, status: :ok
        end
      end
end
