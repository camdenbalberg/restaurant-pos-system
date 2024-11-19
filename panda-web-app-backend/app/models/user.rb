class User < ApplicationRecord
  has_secure_token :session_token

  validates :id, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :avatar_url, presence: true
  validates :name, presence: true
end
