class Api::V1::TransactionsController < ApplicationController
  # Query database for items and rendering it as json
  def index
    @transactions = Transaction.all
    render json: @transactions
  end

  # GET /api/v1/employees_controller/id
  # retrieve employee data with id
  def show
    @transaction = Transaction.find(params[:id])

    query_result = case params[:fields]
                   when "employee_id"
                     @transaction = Transaction.find(params[:employee_id])
                   when "transaction_date"
                     @transaction = Transaction.find(params[:transaction_date])
                   else
                     @transaction
                   end

    render json: query_result
  rescue ActiveRecord::RecordNotFound
    render json: { error: "No history or record of transaction id" }, status: :not_found
  end

  # Query transactions for this day
  def by_date
    date = params[:date]

    @transactions = Transaction.where(transaction_date: date)

    if @transactions.any?
      render json: @transactions
    end
  rescue ActiveRecord::RecordNotFound
      render json: { error: "No history or records of transactions on this date"}, status: :not_found
  end

  # Query transactions for this employee
  def by_employee
    employee = params[:employee]

    @transactions = Transaction.where(employee_id: employee)

    if @transactions.any?
      render json: @transactions
    end
  rescue ActiveRecord::RecordNotFound
      render json: { error: "No history or records of transactions for this employee"}, status: :not_found
  end
end
