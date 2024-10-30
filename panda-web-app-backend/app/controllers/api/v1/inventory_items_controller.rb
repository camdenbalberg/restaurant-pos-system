class Api::V1::InventoryItemsController < ApplicationController
  # Show collection of available items in inventory
  def index
    @inventory_items = InventoryItem.all
    render json: @inventory_items
  end

  # GET /api/v1/employees_controller/id
  # retrieve employee data with id
  def show
    @inventory_item = InventoryItem.find(params[:id])

    query_result = case params[:fields]
                   when "name_only"
                     @inventory_item.slice(:inv_name)
                   when "stock"
                     @inventory_item.slice(:stock, :base_stock)
                   else
                     @inventory_item
                   end

    render json: query_result
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Inventory with this id not found" }, status: :not_found
  end
end
