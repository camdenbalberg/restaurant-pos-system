class Transaction < ApplicationRecord
  validates :transaction_id, presence: true, uniqueness: true
  validates :transaction_date, :transaction_time, presence: true
  validates :total_price, presence: true, numericality: true
  validates :current_balance, presence: true, numericality: true
  validates :is_expense, inclusion: { in: [ true, false ] }
  validates :employee_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to_0: true }
end
