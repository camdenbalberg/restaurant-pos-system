class ScreenLock < ApplicationRecord
  validates :screen_type, presence: true, uniqueness: true
  validates :locked, inclusion: { in: [true, false] }

  validates :passkey, presence: true, if: :passkey_present?
  validates :passkey, format: { with: /\A\d{6}\z/, message: "must be a 6-digit numerical string" }, if: :passkey_present?
  
  private

  def passkey_present?
    passkey.present?
  end
end
