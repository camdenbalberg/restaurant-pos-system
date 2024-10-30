class Recipe < ApplicationRecord
  self.primary_key = "menu_id"
  validates :menu_id, presence: true
  validates :inv_id, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to_0: true }
end
