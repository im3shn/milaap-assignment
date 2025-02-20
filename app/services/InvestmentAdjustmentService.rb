class InvestmentAdjustmentService
  def initialize(userId, amount)
    @user = User.find(userId)
    @amount = amount
    @accounts = @user.accounts.map do |acc|
      {
        id: acc.id,
        name: "#{acc.bank.name}" + "-" + "acc.id",
        available_balance: acc.balance - acc.account_type.minimum_balance_needed
      }
    end
  end


  def exact_matcher
    puts "HI from exact matcher"
    exact_matches = []
    @accounts.each do |acc|
      if acc[:available_balance] == @amount
        exact_matches << acc
      end
    end
    puts exact_matches
    exact_matches
  end

  def total_available_balance
    sum = 0

    @accounts.each do |acc|
      sum += acc[:available_balance]
    end

    sum
  end

  def multiple_lesser_matcher
    []
  end

  def next_greater_matcher
    element = @amount
    stk = []
    accounts_greater = []

    @accounts.each do |acc|
      if acc[:available_balance] < element
        next
      end
      if stk.empty? or acc[:available_balance] > stk.last
        stk << acc[:available_balance]
        accounts_greater << acc
      else
        while acc[:available_balance] < stk.last
          stk.pop
          accounts_greater.pop
        end
        stk << acc[:available_balance]
        accounts_greater << acc
      end
    end

    accounts_greater
  end


  def return_value
    total_available_balance_amount = total_available_balance()
    puts total_available_balance_amount
    if total_available_balance_amount < @amount
      puts "not enough"
      return []
    end

    exact_match = exact_matcher()
    puts "st====="
    puts exact_match
    puts "ex end====="
    if !exact_match.empty?
      puts "exact"
      return exact_match.first
    end

    greater_match = next_greater_matcher()
    puts greater_match
    puts "gr end====="
    if !greater_match.empty?
      puts "next greater"
      return greater_match.first
    end

    multiple_lesser_matches = multiple_lesser_matcher()
    puts multiple_lesser_matches
    puts "les end====="
    if !multiple_lesser_matches.empty?
      puts "multiple lesser"
      multiple_lesser_matches

    else
      puts "no match"
      []
    end
  end
end
