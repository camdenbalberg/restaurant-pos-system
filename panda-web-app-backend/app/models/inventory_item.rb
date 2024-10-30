class InventoryItem < ApplicationRecord
  validates :inv_id, presence: true, uniqueness: true
  validates :stock, :base_stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :inv_name, uniqueness: true
end
