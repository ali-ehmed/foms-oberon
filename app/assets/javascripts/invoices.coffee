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

  synchronizeInvoicesFromRm: (elem, text = "") ->
    $this = $(elem)
    date_input = $('input#invoice_month_year')
    month_param = date_input.val().split('-')[0]
    year_param = date_input.val().split('-')[1]
    no_of_days = $('#no_of_days').val()
    project_id = $("#invoice_projects").val()

    params = {
    	month: $.trim(month_param)
    	year: $.trim(year_param)
    	no_of_days: no_of_days
    }

    # If Project based sync
    if $this.data("isproject") == true
    	params["invoice_projects"] = project_id

    swal {
      title: text
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: 'rgb(221, 107, 85) !important;'
      confirmButtonText: 'Sure!'
      closeOnConfirm: false
    }, ->
      $.ajax
        type: $this.data('method')
        url: $this.data('action')
        dataType: 'json'
        data: params
        cache: false
        beforeSend: ->
          swal
            title: '<span class="fa fa-spinner fa-spin fa-3x"></span>'
            text: '<h2>Synchronization is in progress</h2>'
            html: true
            showConfirmButton: false
        success: (response, data) ->
          switch response.status
            when 'http_error_404' then swal 'Synchronization Stopped', '' + response.message, 'error'
            when 'error' then swal 'Synchronization Stopped', '' + response.message, 'error'
            else
              swal
              	title: 'Synchronization Completed'
              	text: "#{response.message}"
              	type: 'success'
              	html: true
          return
        error: (response) ->
          swal 'Oops', 'Something went wrong'
          false
          return
window.syncInvoices = (elem, text = "") ->
	$invoices.synchronizeInvoicesFromRm(elem, text)

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
		onSwitchChange: (event, state) ->
			if state == false
				$("#invoice_projects_select").slideUp(500).fadeTo 500, 0, ->
	    		$(this).hide()
			else
				$("#invoice_projects_select").slideDown(500).fadeTo 0, 500, ->
	    		$(this).show()
		)

	$("[name='invoice_employee']").bootstrapSwitch(
		size: "small"
		onColor: "success"
		onText: "Yes"
		offText: "No"
		labelText: "Employee"
		state: false
		onSwitchChange: (event, state) ->
			if state == false
				$("#invoice_employees_select").slideUp(500).fadeTo 500, 0, ->
	    		$(this).hide()
			else
				$("#invoice_employees_select").slideDown(500).fadeTo 0, 500, ->
	    		$(this).show()
		)

	$("#invoice_projects").select2
		placeholder: "--Select Project--",
		allowClear: true

	$("#invoice_employees").select2
	  placeholder: "--Select Employee--",
		allowClear: true

	$('#no_of_days').TouchSpin 
		initval: 40
		max: 31
		min: 0
		booster: true