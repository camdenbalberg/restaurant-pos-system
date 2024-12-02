class Customer < ApplicationRecord
  validates :id, presence: true, uniqueness: true
  validates :loyalty_points, presence: true
  validates :birthday, presence: true
  validates :phone, uniqueness: true
end
