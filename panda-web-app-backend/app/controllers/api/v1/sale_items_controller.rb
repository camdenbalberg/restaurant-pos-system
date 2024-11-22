class Api::V1::SaleItemsController < ApplicationController

    def index
        @saleitems = SaleItem.all
        render json: @saleitems
    end
    
    #GET /api/v1/sale_items_controller/by_transaction_id/##
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

    def by_transaction_id
        id = params[:id]

        @saleitems = SaleItem.where(transaction_id: id)

        if @saleitems.any?
            render json: @saleitems
        end
    rescue ActiveRecord::RecordNotFound
        render json: { error: "No history or records of transactions for this employee"}, status: :not_found
    end

    def add_sale_item
        menu_id = params[:menu_id]
        quantity = params[:quantity]
        price = params[:price]
        Rails.logger.info "#{menu_id} : #{quantity} : #{price}"
          # Check if all required parameters are present
        if menu_id.nil? || quantity.nil? || price.nil?
          render json: { error: 'Missing parameters: menuId, quantity, or price' }, status: :unprocessable_entity
          return
        end

        highest_sale_id = SaleItem.maximum(:transaction_id) || 0  # Returns 0 if no menu_items exist
        Rails.logger.info "#{highest_sale_id}"
        new_sale_id = highest_sale_id + 1

        Rails.logger.info "Received parameters: menuName = #{menu_id}, category = #{quantity}, price = #{price}"
        # Create new SaleItem instance
        sale_item = SaleItem.new(transaction_id: new_sale_id, menu_id: menu_id, quantity: quantity, price: price)
        if sale_item.save
          render json: sale_item, status: :created
        else
          render json: { error: 'Failed to create menu item' }, status: :unprocessable_entity
        end
      end
  end