# inventory_items_controller.rb
class Api::V1::InventoryItemsController < ApplicationController

  # GET /api/v1/inventory_items
  # @description
  # Retrieves all inventory items from the database.
  # @returns [Array<InventoryItem>] List of all inventory items in JSON format
  def index
    @inventory_items = InventoryItem.all
    render json: @inventory_items
  end


  # GET /api/v1/inventory_items/:id
  # @description
  # Retrieves a specific inventory item by ID with optional field filtering.
  # @param id [Integer] The unique identifier of the inventory item
  # @param fields [String] Optional parameter to filter returned fields:
  #   - "name_only": Returns only the item name
  #   - "stock": Returns current and base stock levels
  # @returns [InventoryItem] The requested inventory item data in JSON format
  # @raises ActiveRecord::RecordNotFound if item is not found
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


  # POST /api/v1/inventory_items
  # @description
  # Creates a new inventory item. Automatically generates a new inventory ID.
  # @param inv_name [String] Name of the inventory item
  # @param stock [Integer] Current stock quantity
  # @param base_stock [Integer] Base stock level for reordering
  # @returns [InventoryItem] The newly created inventory item in JSON format
  # @raises [UnprocessableEntity] if creation fails
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


  # PATCH /api/v1/inventory_items/:id
  # @description
  # Updates an existing inventory item's information.
  # @param id [Integer] The unique identifier of the inventory item
  # @param inv_name [String] Updated item name
  # @param stock [Integer] Updated stock quantity
  # @param base_stock [Integer] Updated base stock level
  # @returns [InventoryItem] The updated inventory item in JSON format
  # @raises ActiveRecord::RecordNotFound if item is not found
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


  # DELETE /api/v1/inventory_items/:id
  # @description
  # Deletes an inventory item from the system.
  # @param id [Integer] The unique identifier of the inventory item
  # @returns [String] Success message in JSON format
  # @raises ActiveRecord::RecordNotFound if item is not found
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


  # PATCH /api/v1/inventory_items/:id/update_stock
  # @description
  # Updates the stock quantity of an inventory item.
  # Subtracts the used quantity from current stock.
  # @param id [Integer] The unique identifier of the inventory item
  # @param quantity_used [Integer] Amount of stock used/removed
  # @returns [Hash] Updated stock information in JSON format
  # @raises ActiveRecord::RecordNotFound if item is not found
  def update_stock
    @inventory_item = InventoryItem.find(params[:id])
    quantity_used = params[:quantity_used]

    if @inventory_item && quantity_used
      # Subtract the used quantity from the stock
      @inventory_item.update(stock: @inventory_item.stock - quantity_used)
      render json: { success: 'Inventory updated successfully', stock: @inventory_item.stock }, status: :ok
    else
      render json: { error: 'Failed to update inventory or invalid quantity' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Inventory item not found" }, status: :not_found
  end

  private
  
  # @description
  # Strong parameters for inventory items
  # @returns [ActionController::Parameters] Permitted parameters for inventory items
  def inventory_params
    params.permit(:inv_name, :stock, :base_stock)
  end
end
