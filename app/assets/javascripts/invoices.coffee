$invoices =
  init: ->
    ### Initializing Methods ###
    $invoices.getInvoiceNumber()
    return
  getInvoiceNumber: ->
    $input = $('input[name=\'no_of_days\']')
    url = $input.data('invoice-no-url')
    $.get url, (response) ->
      $input.val response.invoice_number
      return

  syncAllInvoices: (elem) ->
	  $this = $(elem)
	  date_input = $('input#invoice_month_year')
	  month_param = date_input.val().split('-')[0]
	  year_param = date_input.val().split('-')[1]
	  no_of_days = $("#no_of_days").val()
	  swal {
	    title: 'Synchronize?'
	    type: 'warning'
	    showCancelButton: true
	    confirmButtonColor: 'rgb(221, 107, 85) !important;'
	    confirmButtonText: 'Sure!'
	    closeOnConfirm: false
	  }, ->
			  $.ajax
				  type: 'Get'
				  url: $this.data("url")
				  dataType: "json"
				  data:
				    month: month_param
				    year: year_param
				    no_of_days: no_of_days
				  cache: false
				  beforeSend: ->
				    swal
					    title: "<span class=\"fa fa-spinner fa-spin fa-3x\"></span>"
					    text: "<h2>Synchronization is in progress</h2>"
					    html: true
					    showConfirmButton: false
			    success: (response, data) ->
			    	switch response.status
			    		when "http_error_404" then swal 'Synchronization Stopped', "#{response.message}", "error"
		    			when "error" then swal 'Synchronization Stopped', "#{response.message}", "error"
		    			else
		    				swal 'Synchronization Completed', "#{response.message}", "success"
		      error: (response) ->
		        swal 'oops', 'Something went wrong'
		        false
		        return
    

window.syncAllInvoices = (elem) ->
	$invoices.syncAllInvoices(elem)

$(document).on "page:change", ->
	$invoices.init()

	$('#invoice_month_year').datepicker(
      format: 'm - yyyy'
      orientation: 'bottom left'
      minViewMode: 1
  	).on 'changeDate', (e) ->
    	$(this).datepicker 'hide'


	$("[name='invoice_project']").bootstrapSwitch(
		size: "small"
		onColor: "info"
		onText: "Yes"
		offText: "No"
		state: true
		labelText: "Project"
		onSwitchChange: ->
		)

	$("[name='invoice_employee']").bootstrapSwitch(
		size: "small"
		onColor: "success"
		onText: "Yes"
		offText: "No"
		labelText: "Employee"
		onSwitchChange: ->
		)

	$("#invoice_projects").select2
	  placeholder: "--Select Project--",
		allowClear: true

	$("#invoice_employees").select2
	  placeholder: "--Select Employee--",
		allowClear: true

	$('#no_of_days').TouchSpin initval: 40