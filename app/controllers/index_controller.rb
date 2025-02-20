class IndexController < ApplicationController
  def invest
    if params[:userId] and params[:investment]
      service = InvestmentAdjustmentService.new(params[:userId], params[:investment])
      @values = service.return_value
      @accounts = service.get_accounts_of_user
      puts @values.to_s + " is the return value"
    end
  end
end
