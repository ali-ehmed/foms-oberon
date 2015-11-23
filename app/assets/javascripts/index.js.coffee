$(document).on "page:change", ->
	employee = new Employee
	employee.createQualification()
	employee.createFamilyDetails()