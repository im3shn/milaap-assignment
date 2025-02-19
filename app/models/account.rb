class Account < ApplicationRecord
  belongs_to :user
  belongs_to :bank
  belongs_to :account_type
end
