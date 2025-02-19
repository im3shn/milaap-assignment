class AccountType < ApplicationRecord
  has_many :accounts
  belongs_to :bank
end
