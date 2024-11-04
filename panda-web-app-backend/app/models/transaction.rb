class Transaction < ApplicationRecord
  validates :transaction_id, presence: true, uniqueness: true
  validates :transaction_date, :transaction_time, presence: true
  validates :total_price, presence: true, numericality: true
  validates :current_balance, presence: true, numericality: true
  validates :is_expense, inclusion: { in: [ true, false ] }
  validates :employee_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to_0: true }
  validates :completed, inclusion: { in: [ true, false ] }

  def as_json(options = {})
    super(options.merge(methods: :formatted_transaction_time, except: :transaction_time))
  end

  # Custom method for formatted time with seconds
  def formatted_transaction_time
    transaction_time.strftime("%H:%M")  # Formats as 'HH:MM' in 24-hour format
  end
end
