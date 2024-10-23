class MenuItem < ApplicationRecord
  validates :menu_id, presence: true
  validates :menu_name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true
end
