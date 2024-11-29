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

  def add_customer
    customer_phone = params[:phone]
    customer_birthday = params[:birthday]
    customer_points = params[:loyalty_points]

    # Check for missing parameters
    if customer_phone.nil? || customer_birthday.nil? || customer_points.nil?
      render json: { error: 'Missing parameters' }, status: :unprocessable_entity
      return
    end

    highest_customer_id = Customer.maximum(:id) || 0  # Returns 0 if no customers exist
    Rails.logger.info "#{highest_customer_id}"
    new_customer_id = highest_customer_id + 1

    Rails.logger.info "Received parameters"
    # Create new Customer instance
    customer = Customer.new(id: new_customer_id, phone: customer_phone, birthday: customer_birthday, loyalty_points: customer_points)
    if customer.save
      render json: customer, status: :created
    else
      render json: { error: 'Failed to create customer' }, status: :unprocessable_entity
    end
  end

  def by_phone
    customer_phone = params[:phone]

    Rails.logger.info "Checking if customer exists with phone: #{customer_phone}"
    @customers = Customer.where(phone: customer_phone)
    if @customers.any?
      render json: @customers
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "No customers found for this phone"}, status: :not_found
  end

  def add_points
    @customer = Customer.find(params[:id])
    customer_points = params[:loyalty_points]

    update_params = {
      loyalty_points: customer_points
    }

    if @customer.update(update_params)
      render json: @customer, status: :ok
    else
      render json: { error: 'Failed to update customer' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Customer not found" }, status: :not_found
  end

end