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

  # POST /api/v1/customers/add_customer
  # @description
  # Enroll a Customer in the loyalty program by adding them to the database
  # @param phone [String] The Customer's phone number
  # @param birthday [Date] The Customer's birthday
  # @param loyalty_points[Integer] The starting number of loyalty points
  # @returns [String] Success message in JSON format if deletion is successful
  # @raises [UnprocessableEntity] if deletion fails
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

  # GET /api/v1/customers/by_phone
  # @description
  # Finds Customers by their phone number
  # @param phone [String] The phone number to find Customers by
  # @returns [Array<Customer>] List of matching Customers in JSON format
  # @raises ActiveRecord::RecordNotFound if no Customers found with given ID
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

  # PUT /api/v1/employees/:id
  # @description
  # Updates an existing Customer's loyalty points (can increase or decrease)
  # @param id [Integer] The unique identifier of the Customer
  # @returns [Customer] The updated Customer in JSON format
  # @raises ActiveRecord::RecordNotFound if Customer is not found
  # @raises [UnprocessableEntity] if required parameters are missing
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