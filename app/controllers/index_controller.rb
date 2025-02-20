class IndexController < ApplicationController
  def index
  end

  def invest
    service = InvestmentAdjustmentService.new(params[:userId].to_i, params[:investment].to_i)
    puts service.return_value.to_s + " is the return value"
  end
end
