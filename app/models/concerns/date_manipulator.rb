module DateManipulator
	def speak_with_block(&block)
	  block.call
	end

	def speak_with_yield
	  yield
	end

	def payroll_month
    @month = -1
    current_month_payroll = Payroll.get_month_and_year_of_incompleted.first
    @month = current_month_payroll.month

    return @month.to_s
  end

  def payroll_year
    @year = -1
    current_year_payroll = Payroll.get_month_and_year_of_incompleted.first
    @year = current_year_payroll.year

    return @year.to_s  
  end

	def payroll_end_date
    @month = payroll_month 
    @year = payroll_year  
    
    @end_date = "#{@year}-#{@month}-25"

    return @end_date
  end

  def payroll_date_for_salary
    @month = payroll_month.to_i  
    @year = payroll_year.to_i
    @month = Payroll.last.month.to_i + 1 if @month == -1
		@year = Payroll.last.year.to_i if @year == -1
    
		@payroll_date = "#{@year}-#{@month}-25"
    
    return @payroll_date
  end

  module_function :payroll_end_date, :payroll_date_for_salary, :payroll_month, :payroll_year
end