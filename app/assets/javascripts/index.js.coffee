$(document).on "page:change", ->
	employee = new Employee
	employee.createEmployeeOtherDetails("qualifications", "#employee_qualification_form")
	employee.createEmployeeOtherDetails("education_details", "#employee_family_details_form")
