class EmployeeRecord < ApplicationRecord
    validates :employee_id, presence: true
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true
    validates :is_manager, presence: true
    validates :hiring_date, presence: true
    validates :phone_number, presence: true
    validates :password, presence: true
    validates :is_working, presence: true
  end
  
