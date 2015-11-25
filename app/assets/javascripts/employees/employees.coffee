class window.Employee extends EmployeeFormDetail
	@submitQualificationForm: (elem) ->
		self = $(elem)
		self.closest("#employee_qualification_form").submit()

	@submitFamilyDetailForm: (elem) ->
		self = $(elem)
		self.closest("#employee_family_details_form").submit()

	createEmployeeOtherDetails: (_for = "", elem) ->
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
			        text: "Please Review Errors Below: #{response.message}"
		        	purr_type: "error"
		    	else
		        $.purrAlert("", text: "Record has created", purr_type: "success")
		        self.find(":input").not(":button").val('')
		    		console.log "Status: Created"
		    error: (response) ->
		    	$.purrAlert '',
		    		html: true
		    		text: "Something went wrong"
		    		purr_type: "error"

	@removeEmployeeOtherDetails: (elem) ->
    self = $(elem)
    $.ajax
      type: self.data('method')
      url: self.data('href')
      dataType: 'JSON'
      beforeSend: ->
      success: (response, data) ->
        $.purrAlert '',
          text: 'Record removed'
          purr_type: 'success'
        self.closest('tr').fadeOut()
      error: (response) ->
        $.purrAlert '',
          text: 'Something went wrong'
          purr_type: 'error'
        return
	
	@submitEmpForm: (elem) ->
	  $(elem).closest(".emp_modal").find("#new_employee_form").submit()

  @createEmployee: ->
	  $form = $('#new_employee_form')
	  $modal_ = $form.closest(".emp_modal")
	  params = $form.serialize()
	  $.ajax
	    type: $form.attr('method')
	    url: $form.attr('action')
	    data: params
	    dataType: 'JSON'
	    beforeSend: ->
	    success: (response, data) ->
	    	if response.status == "error"
	    		$.purrAlert '',
		        text: "Please Review the Errors Below: <br /> #{response.message}"
		        html: true
		        purr_type: 'error'
	    	else
		      swal("Success", "#{response.message}", "success")
		      $modal_.modal("hide")
		      $modal_.on 'hidden.bs.modal', ->
		      	$("#fetch_invoices_btn").trigger("click")
	    error: (response) ->
	      $.purrAlert '',
	        text: 'Something went wrong'
	        purr_type: 'error'
	      return



  



