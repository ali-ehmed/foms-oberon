namespace :employee_associations do
  desc "This is to destroy the models associated to employee by Employee Id"
  task :destroy_employee_associations, [:employee_id] => :environment do |t, args|
  	employee = Employee::Employeepersonaldetail.find_by_EmployeeID(args.employee_id)
  	if employee.present?
	  	employee.qualifications.destroy_all
	  	employee.family_details.destroy_all
	  	employee.employee_salary.destroy
	  	employee.employee_benefit.destroy
	  	employee.employee_family.destroy
	  	employee.bank_account_detail.destroy
	  	puts "Destroyed"
	  else
	  	puts "Employee Not Found"
	  end
  end

  desc "This is to destroy the models associated to employee by Employee Id"
  task :destroy_associations_only, [:employee_id] => :environment do |t, args|
  	education_details = Employee::Educationdetail.where("EmployeeID = ?", args.employee_id)
  	education_details.destroy_all if education_details.present?

  	family_details = Employee::Employeefamilydetail.where("EmployeeID = ?", args.employee_id)
  	education_details.destroy_all if education_details.present?

  	employee_benefit = Employee::Employeebenefit.find_by_EmployeeID(args.employee_id)
  	employee_benefit.destroy if employee_benefit.present?

  	employee_account = Employee::Employeebankaccountdetail.find_by_EmployeeID(args.employee_id)
  	employee_account.destroy if employee_account.present?

  	employee_family = Employee::Employeefamily.find_by_EmployeeID(args.employee_id)
  	employee_family.destroy if employee_family.present?

  	employee_salary = Employee::Employeesalary.find_by_EmployeeID(args.employee_id)
  	employee_salary.destroy if employee_salary.present?

  	puts "Records removed for Employee: #{args.employee_id}"
  end

  desc "This is to revert Current Invoice back with unregistered_employee_id"
  task :update_current_invoices => :environment do |t, args|
		ids = ENV['EMPLOYEE_IDS'].split(',')
  	invoice = CurrentInvoice.where("employee_id = ?", ids.first)
  	invoice.update_all(employee_id: ids.last)
  	puts "Current Invoice for new employee id: #{ids.first} replaced with old employee id: #{ids.last}"
	end

end
