class Api::V1::EmployeesController < ApplicationController
  # Query database for items and rendering it as json

  skip_before_action :verify_authenticity_token, only: [:add_employee]
  skip_before_action :verify_authenticity_token, only: [:delete_employee]
  skip_before_action :verify_authenticity_token, only: [:edit_employee]

  def index
    @employees = Employee.all
    render json: @employees
  end

  # GET /api/v1/employees_controller/id
  # retrieve employee data with id
  def show
    @employee = Employee.find(params[:id])

    query_result = case params[:fields]
                   when "name_only"
                     @employee.slice(:first_name, :last_name)
                   when "is_manager"
                     @employee.slice(:is_manager)
                   when "is_active"
                     @employee.slice(:is_working)
                   when "contact_info"
                     @employee.slice(:email, :phone_number)
                   else
                     @employee
                   end

    render json: query_result
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Employee with this id not found" }, status: :not_found
  end

  def by_password
    pwd = params[:password]
    @employees = Employee.where(password: pwd)
    if @employees.any?
      render json: @employees
    end

  rescue ActiveRecord::RecordNotFound
      render json: { error: "No employees found for this password"}, status: :not_found
  end


  def by_employee_id
    usr = params[:employee_id]
    @employees = Employee.where(employee_id: usr)
    if @employees.any?
      render json: @employees
    end

  rescue ActiveRecord::RecordNotFound
      render json: { error: "No employees found for this username"}, status: :not_found
  end

  # POST /api/v1/employees/add_employee
  def add_employee
    # validates :employee_id, presence: true
    # validates :first_name, presence: true
    # validates :last_name, presence: true
    # validates :email, presence: true
    # validates :is_manager, presence: true
    # validates :hiring_date, presence: true
    # validates :phone_number, presence: true
    # validates :password, presence: true
    # validates :is_working, presence: true

    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    is_manager = params[:is_manager]
    hiring_date = params[:hiring_date]
    phone_number = params[:phone_number]
    password = params[:password]
    is_working = params[:is_working]



      # Check if all required parameters are present
    if first_name.nil? || last_name.nil? || email.nil? || is_manager.nil? || hiring_date.nil? || phone_number.nil? || password.nil? || is_working.nil?
      render json: { error: 'Missing parameters' }, status: :unprocessable_entity
      return
    end

    highest_employee_id = Employee.maximum(:employee_id) || 0  # Returns 0 if no menu_items exist
    Rails.logger.info "#{highest_employee_id}"
    new_employee_id = highest_employee_id + 1

    Rails.logger.info "Received parameters"
    # Create new MenuItem instance
    employee = Employee.new(employee_id: new_employee_id, first_name: first_name, last_name: last_name, email: email, is_manager: is_manager, hiring_date: hiring_date, phone_number: phone_number, password: password, is_working: is_working)
    if employee.save
      render json: employee, status: :created
    else
      render json: { error: 'Failed to create employee' }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/employees/delete_employee
  def delete_employee
    @employee = Employee.find(params[:id])
    if @employee.destroy
      render json: { success: 'Employee deleted' }, status: :ok
    else
      render json: { error: 'Failed to delete employee' }, status: :unprocessable_entity
    end
  end

  def edit_employee
    @employee = Employee.find(params[:id])
    
    # Extract parameters
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = params[:email]
    is_manager = params[:is_manager]
    hiring_date = params[:hiring_date]
    phone_number = params[:phone_number]
    password = params[:password]
    is_working = params[:is_working]
  
    # Check if required parameters are present
    if first_name.nil? || last_name.nil? || email.nil? || is_manager.nil? || 
       hiring_date.nil? || phone_number.nil? || is_working.nil?
      render json: { error: 'Missing parameters' }, status: :unprocessable_entity
      return
    end
  
    # Only update password if it's provided (not empty)
    update_params = {
      first_name: first_name,
      last_name: last_name,
      email: email,
      is_manager: is_manager,
      hiring_date: hiring_date,
      phone_number: phone_number,
      is_working: is_working
    }
    
    # Only include password in update if it's not empty
    update_params[:password] = password if password.present?
  
    if @employee.update(update_params)
      render json: @employee, status: :ok
    else
      render json: { error: 'Failed to update employee' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Employee not found" }, status: :not_found
  end

end


