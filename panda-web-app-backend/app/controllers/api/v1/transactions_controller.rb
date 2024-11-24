class Api::V1::TransactionsController < ApplicationController
  # Query database for items and rendering it as json

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

  def by_date_range
    start_date = params[:start_date]
    end_date = params[:end_date]
    Rails.logger.info("Start : #{start_date} End : #{end_date}")
    @transactions = Transaction.where(transaction_date: start_date..end_date)
  
    if @transactions.any?
      render json: @transactions
    else
      render json: { error: "No transactions found in this date range" }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Error fetching transactions" }, status: :not_found
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

  def highest_transaction_id
    highest_id = Transaction.maximum(:transaction_id) || 0
    render json: { transaction_id: highest_id }, status: :ok
  end

  def add_transaction
    transaction_params = params.require(:transaction).permit(:date, :time, :total_cost, :expense)

    transaction_date = transaction_params[:date]
    transaction_time = transaction_params[:time]
    total_price = transaction_params[:total_cost]
    is_expense = transaction_params[:expense]

      # Check if all required parameters are present
    if transaction_date.nil? || transaction_time.nil? || total_price.nil? || is_expense.nil?
      render json: { error: 'Missing parameters: transaction_date, transaction_time, total_price, is_expense' }, status: :unprocessable_entity
      return
    end

    highest_transaction_id = Transaction.maximum(:transaction_id) || 0  # Returns 0 if no menu_items exist
    Rails.logger.info "#{highest_transaction_id}"
    new_transaction_id = highest_transaction_id + 1

    Rails.logger.info "Received parameters: transaction_date = #{transaction_date}, transaction_time = #{transaction_time}, total_price = #{total_price}, is_expense = #{is_expense}"
    balance = Transaction.find_by(transaction_id: highest_transaction_id).current_balance + total_price;
    # Create new TransactionItem instance
    new_transaction = Transaction.new(transaction_id: new_transaction_id, transaction_date: transaction_date, transaction_time: transaction_time, total_price: total_price, is_expense: is_expense, current_balance: balance,employee_id: 0, completed: false)
    if new_transaction.save
      Rails.logger.info "Transaction created successfully: #{new_transaction.inspect}"
      render json: new_transaction, status: :created
    else
      Rails.logger.error "Failed to create transaction: #{new_transaction.errors.full_messages.join(', ')}"
      render json: { error: 'Failed to create transaction', details: new_transaction.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
