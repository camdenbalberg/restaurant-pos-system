# inventory_items_controller.rb
class Api::V1::InventoryItemsController < ApplicationController


  def index
    @inventory_items = InventoryItem.all
    render json: @inventory_items
  end

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
    render json: { error: "Inventory item not found" }, status: :not_found
  end

  def create
    highest_inv_id = InventoryItem.maximum(:inv_id) || 0
    new_inv_id = highest_inv_id + 1

    inventory_item = InventoryItem.new(
      inv_id: new_inv_id,
      inv_name: params[:inv_name],
      stock: params[:stock],
      base_stock: params[:base_stock]
    )

    if inventory_item.save
      render json: inventory_item, status: :created
    else
      render json: { error: 'Failed to create inventory item' }, status: :unprocessable_entity
    end
  end

  def update
    @inventory_item = InventoryItem.find(params[:id])
    
    if @inventory_item.update(inventory_params)
      render json: @inventory_item, status: :ok
    else
      render json: { error: 'Failed to update inventory item' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Inventory item not found" }, status: :not_found
  end

  def destroy
    @inventory_item = InventoryItem.find(params[:id])
    
    if @inventory_item.destroy
      render json: { success: 'Inventory item deleted' }, status: :ok
    else
      render json: { error: 'Failed to delete inventory item' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Inventory item not found" }, status: :not_found
  end

  private

  def inventory_params
    params.permit(:inv_name, :stock, :base_stock)
  end
end