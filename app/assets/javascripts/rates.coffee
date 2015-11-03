syncingAllDesignations = ->
	$("#sync_all_designations").on "click", (e) ->
		e.preventDefault()
		$this = $(this)
		revision_date_val = $("select[name='revision_date']").val()
		swal {
		  title: "Sync All Designations?"
		  type: 'warning'
		  showCancelButton: true
		  confirmButtonColor: '#DD6B55'
		  confirmButtonText: 'Sync All'
		  cancelButtonText: 'Cancel'
		  closeOnConfirm: false
		  closeOnCancel: true
		}, (isConfirm) ->
		  if isConfirm
		    $.ajax
		      type: 'Get'
		      url: $this.data("url")
		      # data: { revision_date: if !revision_date_val then null else revision_date_val }
		      cache: false
		      beforeSend:
		      	swal
		      		title: "<span class=\"fa fa-spinner fa-spin fa-3x\"></span>"
		      		text: "<h2>Syncronizing</h2>"
		      		html: true
		      		showConfirmButton: false
		      success: (response, data) ->
		      	# if !revision_date_val
	        # 		swal 'Designations', "Synchronized. Please select date to get rates.", "success"
	        # 	else
        		swal 'Designations', "Synchronized", "success"
		      error: (response) ->
		        swal 'oops', 'Something went wrong'
		    false
		  else
		    swal 'Cancelled', '', 'error'
		  return

window.submitRatesForm = ->
	$("#revision_date").on "change", ->
		$(this).closest("form#rates_form").submit()
		return false

getRates = ->
	$("form#rates_form").on "submit", (e) ->
		e.preventDefault()
		$form = $(this)
		rev_date = $form.find("#revision_date").val()
		$.ajax
      type: $form.attr("method")
      url: $form.attr("action")
      data: { revision_date: rev_date }
      success: (response, data) ->
      	console.log("OK")
      error: (response) ->
        swal 'oops', 'Something went wrong'

window.getDesignationRateHistory = (elem) ->
	$this = $(elem)
	$desig_id = $this.data("designation-id")
	$url = "/rates/#{$desig_id}/designation_rate_history.js"
	$.ajax
    type: "Get"
    url: $url
    data: { designation_id: $desig_id }
    success: (response, data) ->
    	console.log("#{$desig_id}")
    error: (response) ->
      swal 'oops', 'Something went wrong'

saveDesignationRate = ->
	$("#save_rate").on "click", (e) ->
		e.preventDefault()
		$this = $(this)
		$form = $this.closest("form")
		revision_date_val = $("select[name='revision_date']").val()

		$form_data = $form.serializeArray()

		if revision_date_val
			$form_data.push
			  name: 'revision_date'
			  value: revision_date_val

		$.ajax
	    type: $form.attr("method")
	    url: $form.attr("action")
	    data: $form_data
	    success: (response, data) ->
	    	if response.status == 'error'
          swal
            title: 'Couldn\'t save'
            text: response.errors
            type: 'error'
            html: true
          console.log 'Couldn\'t save'
        else
          if !revision_date_val
            swal 'Designations Rate', "Saved. Please select date to get rates.", "success"
          else
            swal 'Designations Rate', "Saved", "success"

          $this.closest(".modal").modal 'hide'
          $form.find(':input').val ''
	    error: (response) ->
	      swal 'oops', 'Something went wrong'

$(document).on "page:change", ->
	syncingAllDesignations()
	submitRatesForm()
	getRates()
	saveDesignationRate()

	$("#designation").select2
	  placeholder: "Choose Designation",
		allowClear: true