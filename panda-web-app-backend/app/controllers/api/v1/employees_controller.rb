class Api::V1::EmployeesController < ApplicationController
  # Query database for items and rendering it as json
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
end
