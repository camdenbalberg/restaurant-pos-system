class Api::V1::TransactionsController < ApplicationController
  # Query database for items and rendering it as json
  skip_before_action :verify_authenticity_token, only: [:toggle_completed]
  
  def index
    @transactions = Transaction.all
    render json: @transactions
  end

  # GET /api/v1/transactions_controller/id
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
  
  def toggle_completed
    @transaction = Transaction.find(params[:id])
    Rails.logger.info("help :  #{@transaction}")
    # @transaction = Transaction.where(transaction_id: id)
    @transaction.completed = !@transaction.completed # Toggle the completed status
    if @transaction.save
      render json: @transaction, status: :ok
    else
      Rails.logger.error(@transaction.errors.full_messages.join(", "))
      render json: { error: 'Failed to update transaction status.' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Transaction not found" }, status: :not_found
  end
end
