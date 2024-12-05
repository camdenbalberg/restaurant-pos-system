class Api::V1::SaleItemsController < ApplicationController
  # GET /api/v1/sale_items
  # @description
  # Retrieves all sale items in the system.
  # @returns [Array] A list of all sale items in JSON format.
    def index
        @saleitems = SaleItem.all
        render json: @saleitems
    end
    
    # GET /api/v1/sale_items/:id
    # @description
    # Retrieves a specific sale item based on the given ID. Optionally, it can return the sale item 
    # filtered by the "transaction_id" if specified in the query parameters.
    # @param id [Integer] The ID of the sale item to retrieve.
    # @param fields [String] Optional. If 'transaction_id' is specified, returns the sale item matching the transaction ID.
    # @returns [SaleItem] The sale item in JSON format or an error message if not found.
    # @raises ActiveRecord::RecordNotFound if the sale item is not found.
    def show
        @saleitem = SaleItem.find(params[:id])

        query_result = case params[:fields]
                       when "transaction_id"
                        @saleitem = SaleItem.find(params[:transaction_id])
                       else
                        @saleitem
                       end

        render json: query_result

    rescue ActiveRecord::RecordNotFound
        render json: { error: "No history or record of transaction id" }, status: :not_found
    end

    # GET /api/v1/sale_items/by_transaction_id/:id
    # @description
    # Retrieves all sale items related to a specific transaction ID.
    # @param id [String] The transaction ID used to filter the sale items.
    # @returns [Array] A list of sale items associated with the specified transaction ID.
    # @raises ActiveRecord::RecordNotFound if no sale items are found with the given transaction ID.
    def by_transaction_id
        id = params[:id]

        @saleitems = SaleItem.where(transaction_id: id)

        if @saleitems.any?
            render json: @saleitems
        end
    rescue ActiveRecord::RecordNotFound
        render json: { error: "No history or records of transactions for this employee"}, status: :not_found
    end

    # GET /api/v1/sale_items/by_transaction_ids
    # @description
    # Retrieves sale items associated with a list of transaction IDs.
    # @param transaction_ids [Array] An array of transaction IDs used to filter the sale items.
    # @returns [Array] A list of sale items associated with the specified transaction IDs.
    def by_transaction_ids
      transaction_ids = params[:transaction_ids]
      @saleitems = SaleItem.where(transaction_id: transaction_ids)
      render json: @saleitems
    end

    # POST /api/v1/sale_items/add_sale_item
    # @description
    # Adds a new sale item to the system. The new sale item is linked to the latest transaction ID.
    # @param menu_id [Integer] The menu ID of the item being sold.
    # @param quantity [Integer] The quantity of the item sold.
    # @param price [Decimal] The price of the item.
    # @param transaction_id [Integer] The ID of the transaction to which the sale item is associated.
    # @returns [SaleItem] The newly created sale item in JSON format or an error message if creation fails.
    # @raises ActionController::ParameterMissing if any required parameters are missing.
    def add_sale_item
        menu_id = params[:menu_id]
        quantity = params[:quantity]
        price = params[:price]
        transaction_id = params[:transaction_id]

        Rails.logger.info "#{menu_id} : #{quantity} : #{price}"
          # Check if all required parameters are present
        if menu_id.nil? || quantity.nil? || price.nil?
          render json: { error: 'Missing parameters: menuId, quantity, or price' }, status: :unprocessable_entity
          return
        end

        latest_transaction_id = Transaction.maximum(:transaction_id) || 0  # Returns 0 if no menu_items exist
        Rails.logger.info "#{latest_transaction_id}"

        Rails.logger.info "Received parameters: menuName = #{menu_id}, category = #{quantity}, price = #{price}"
        # Create new SaleItem instance
        sale_item = SaleItem.new(transaction_id: latest_transaction_id, menu_id: menu_id, quantity: quantity, price: price)
        if sale_item.save
          render json: sale_item, status: :created
        else
          render json: { error: 'Failed to create menu item' }, status: :unprocessable_entity
        end
      end
  end
