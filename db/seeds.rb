# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Account.destroy_all
AccountType.destroy_all
Bank.destroy_all
User.destroy_all

5.times do |i|
  User.create!(name: "user#{i+1}")
end

5.times do |i|
  Bank.create!(name: "bank#{i+1}")
end

Bank.all.each do |bank|
  min_balance = 1000
  bank.account_types.create!(is_minimum_balance_enforced: false, minimum_balance_needed: 0)
  4.times do
    bank.account_types.create!(is_minimum_balance_enforced: true,
      minimum_balance_needed: min_balance)
    min_balance += 1000
  end
end

users = User.all
balance = 10000
Bank.all.each do |bank|
  account_types = bank.account_types

  5.times do |i|
    bank.accounts.create!(balance: balance, user: users[i], account_type: account_types[i])
    balance += 10000
  end

  balance += 10000
end

users = User.all
balance = 10000
Bank.all.each do |bank|
  account_types = bank.account_types

  2.times do |i|
    bank.accounts.create!(balance: balance, user: users[i], account_type: account_types[i])
  end
end
