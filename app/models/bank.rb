class Bank < ApplicationRecord
  has_many :accounts
  has_many :users, through: :accounts
  has_many :account_types
end
