class Api::V1::CustomersController < ApplicationController
  def index
    @customers = Customer.all
    render json: @customers
  end

  # GET /api/v1/customers_controller/id
  # retrieve customer data with id
  def show
    @customer = Customer.find(params[:id])

    query_result = case params[:fields]
                    when "id"
                    @customer = Customer.find(params[:id])
                    else
                    @customer
                    end

        render json: query_result

  rescue ActiveRecord::RecordNotFound
      render json: { error: "No customer found with given id" }, status: :not_found
  end

  # def loyalty_add_customer
  #   customer_email = params[:customer_email]
  #   customer_birthday = params[:customer_birthday]
  #   customer_points = params[:customer_points]

  # end

  def by_email
    customer_email = params[:email]

    @customers = Customer.where(email: customer_email)
    if @customers.any?
      render json: @customers
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "No customers found for this email"}, status: :not_found
  end

end