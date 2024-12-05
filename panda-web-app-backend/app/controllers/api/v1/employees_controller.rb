class Api::V1::EmployeesController < ApplicationController
  
  
  # GET /api/v1/employees
  # @description
  # Queries the database for all employees and returns them as JSON.
  # @returns [Array<Employee>] List of all employees in JSON format.
  def index
    @employees = Employee.all
    render json: @employees
  end

  # GET /api/v1/employees/:id
  # @description
  # Retrieves employee data by ID with optional field filtering.
  # Supports different views of employee data based on the 'fields' parameter.
  # @param id [Integer] The unique identifier of the employee
  # @param fields [String] Optional parameter to filter returned fields:
  #   - "name_only": Returns only first and last name
  #   - "is_manager": Returns only manager status
  #   - "is_active": Returns only working status
  #   - "contact_info": Returns email and phone number
  # @returns [Employee] The requested employee data in JSON format
  # @raises ActiveRecord::RecordNotFound if employee with given ID is not found
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

  # GET /api/v1/employees/by_password
  # @description
  # Finds employees by their password.
  # @param password [String] The password to search for
  # @returns [Array<Employee>] List of matching employees in JSON format
  # @raises ActiveRecord::RecordNotFound if no employees found with given password
  def by_password
    pwd = params[:password]
    @employees = Employee.where(password: pwd)
    if @employees.any?
      render json: @employees
    end

  rescue ActiveRecord::RecordNotFound
      render json: { error: "No employees found for this password"}, status: :not_found
  end


  # GET /api/v1/employees/by_employee_id
  # @description
  # Finds employees by their employee ID.
  # @param employee_id [Integer] The employee ID to search for
  # @returns [Array<Employee>] List of matching employees in JSON format
  # @raises ActiveRecord::RecordNotFound if no employees found with given ID
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
  # @description
  # Creates a new employee with the provided information.
  # Automatically generates a new employee ID based on the highest existing ID.
  # @param first_name [String] Employee's first name
  # @param last_name [String] Employee's last name
  # @param email [String] Employee's email address
  # @param is_manager [Boolean] Whether the employee is a manager
  # @param hiring_date [Date] Employee's hire date
  # @param phone_number [String] Employee's phone number
  # @param password [String] Employee's password
  # @param is_working [Boolean] Whether the employee is currently active
  # @returns [Employee] The newly created employee in JSON format
  # @raises [UnprocessableEntity] if required parameters are missing
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

  # DELETE /api/v1/employees/:id
  # @description
  # Deletes an employee from the system.
  # @param id [Integer] The unique identifier of the employee to delete
  # @returns [String] Success message in JSON format if deletion is successful
  # @raises [UnprocessableEntity] if deletion fails
  def delete_employee
    @employee = Employee.find(params[:id])
    if @employee.destroy
      render json: { success: 'Employee deleted' }, status: :ok
    else
      render json: { error: 'Failed to delete employee' }, status: :unprocessable_entity
    end
  end


  # PATCH /api/v1/employees/:id
  # @description
  # Updates an existing employee's information.
  # Password is only updated if explicitly provided.
  # @param id [Integer] The unique identifier of the employee
  # @param first_name [String] Updated first name
  # @param last_name [String] Updated last name
  # @param email [String] Updated email address
  # @param is_manager [Boolean] Updated manager status
  # @param hiring_date [Date] Updated hire date
  # @param phone_number [String] Updated phone number
  # @param password [String] Optional new password
  # @param is_working [Boolean] Updated working status
  # @returns [Employee] The updated employee in JSON format
  # @raises ActiveRecord::RecordNotFound if employee is not found
  # @raises [UnprocessableEntity] if required parameters are missing
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


