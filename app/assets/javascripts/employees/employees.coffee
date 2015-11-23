class window.Employee
	@submitQualificationForm: (elem) ->
		self = $(elem)
		self.closest("#employee_qualification_form").submit()

	@submitFamilyDetailForm: (elem) ->
		self = $(elem)
		self.closest("#employee_family_details_form").submit()

	@createEmployeeOtherDetails: (elem) ->
		$(document).on "submit", elem, (e) ->
			e.preventDefault()
			self = $(this)
			params = self.serialize()
			$.ajax
	      type: self.attr("method")
	      url: self.attr("action")
	      data: params
	      cache: false
	      beforeSend: ->
	      success: (response, data) ->
	      	if response.status == "error"
	        	$.purrAlert '',
			        html: true
			        text: "#{response.message}"
		        	purr_type: "error"
        	else
		        $.purrAlert("", text: "Record has created", purr_type: "success")
		        self.find(":input").not(":button").val('')
        		console.log "Status: Created"
	      error: (response) ->
	      	$.purrAlert '',
	      		html: true
	      		text: "#{response}"
	      		purr_type: "error"

	createQualification: ->
		Employee.createEmployeeOtherDetails("#employee_qualification_form")

	createFamilyDetails: ->
		Employee.createEmployeeOtherDetails("#employee_family_details_form")

	@removeEmployeeOtherDetails: (elem) ->
		self = $(elem)
		$.ajax
      type: self.data("method")
      url: self.data("href")
      dataType: "JSON"
      beforeSend: ->
      success: (response, data) ->
      	$.purrAlert("", text: "Record removed", purr_type: "success")
      	self.closest('tr').fadeOut()
      error: (response) ->
        $.purrAlert("", text: "Something went wrong", purr_type: "error")

