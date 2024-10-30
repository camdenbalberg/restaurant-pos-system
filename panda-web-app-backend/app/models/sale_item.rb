class SaleItem < ApplicationRecord
    self.primary_key = "transaction_id"
    validates :transaction_id, presence: true, uniqueness: false
    validates :menu_id, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

end