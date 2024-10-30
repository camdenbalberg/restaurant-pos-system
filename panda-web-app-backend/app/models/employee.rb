class Employee < ApplicationRecord
  validates :employee_id, presence: true, uniqueness: true
  validates :first_name, :last_name, :email, :phone_number, presence: true
  validates :email, uniqueness: true
  validates :is_manager, :is_working, inclusion: { in: [ true, false ] }
end
