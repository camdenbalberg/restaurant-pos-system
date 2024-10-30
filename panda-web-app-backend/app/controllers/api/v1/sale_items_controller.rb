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
  end