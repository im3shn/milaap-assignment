class InvestmentAdjustmentService
  def initialize(userId, amount)
    @user = User.find(userId.to_i)
    @amount = amount.to_f
    @accounts = @user.accounts.includes(:bank).map do |acc|
      {
        id: acc.id,
        name: "#{acc.bank.name}" + "-" + "#{acc.id}",
        available_balance: acc.balance - acc.account_type.minimum_balance_needed,
        balance: acc.balance,
        is_minimum_balance_needed: acc.account_type.is_minimum_balance_enforced,
        minimum_balance_needed: acc.account_type.minimum_balance_needed
      }
    end
    @combinations = combination_helper()
  end

  def get_accounts_of_user
    @accounts
  end


  def exact_matcher
    exact_matches = []
    if  @combinations.key?(@amount) and
         @combinations[@amount][0].length == 1
      exact_matches = @combinations[@amount][0]
    end
    exact_matches_account = @accounts.find { |account| account[:id] == exact_matches.first }
    if !exact_matches_account
      exact_matches_account = []
    end
    [ 0, [ exact_matches_account ], @amount ]
  end

  def total_available_balance
    sum = 0

    @accounts.each do |acc|
      sum += acc[:available_balance]
    end

    sum
  end

  def multiple_lesser_matcher
    lesser_matches = []
    lesser_matched_amount = 0
    remaining = @amount

    while remaining > 0
      if @combinations.key?(remaining)
        lesser_matches = @combinations[remaining][0]
        lesser_matched_amount += remaining
        remaining -= remaining
      else
        stk = []
        @combinations.each do |key, value|
          if key < remaining
            next
          end
          if stk.empty? or key >= stk.last
            stk << key
          else
            while !stk.empty? and key <= stk.last
              stk.pop
            end
            stk << key
          end
        end
        lesser_matches = @combinations[stk.first][0]
        lesser_matched_amount += stk.first
        remaining -= stk.first
      end
    end

    lesser_multiple_accounts = []
    if !lesser_matches.empty?
      lesser_multiple_accounts = @accounts.find_all { |acc| lesser_matches.include?(acc[:id]) }
    end


    [ -1, lesser_multiple_accounts, lesser_matched_amount ]
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
        while !stk.empty? and acc[:available_balance] < stk.last
          stk.pop
          accounts_greater.pop
        end
        stk << acc[:available_balance]
        accounts_greater << acc
      end
    end

    if !accounts_greater.empty?
      matched_accounts = @accounts.find { |account| account[:id] == accounts_greater.first[:id] }
    end
    if matched_accounts == nil or matched_accounts.empty?
      matched_accounts = []
    end

    [ 1, [ matched_accounts ], stk.first ]
  end

  # 0->exact, 1->next greater, -1->multiple lesser
  # -2-> not enough
  def return_value
    total_available_balance_amount = total_available_balance()
    if total_available_balance_amount < @amount
      puts "not enough"
      return [ -2, [], total_available_balance_amount ]
    end

    exact_match = exact_matcher()
    if exact_match[1][0].empty? and exact_match[1][0].length == 1
      puts "exect match"
      return exact_match
    end

    greater_match = next_greater_matcher()
    if !greater_match[1][0].empty?
      puts "next greater"
      return greater_match
    end

    multiple_lesser_matches = multiple_lesser_matcher()
    if !multiple_lesser_matches[1].empty?
      puts "multiple lesser"
      multiple_lesser_matches
    end
  end


  def combination_helper
    sum_map = Hash.new { |hash, key| hash[key] = [] }

    balances = @accounts

    # Generate all possible combinations
    (1..balances.length).each do |r|
      balances.combination(r).each do |combo|
        sum = combo.sum { |acc| acc[:available_balance] }
        account_ids = combo.map { |acc| acc[:id] }
        sum_map[sum] << account_ids
      end
    end

    # Sort each array of combinations by the length of account_ids
    sum_map.each do |sum, combos|
      combos.sort_by! { |account_ids| account_ids.length }
    end

    sum_map
  end
end
