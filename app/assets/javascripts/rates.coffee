syncingAllDesignations = ->
	$("#sync_all_designations").on "click", (e) ->
		e.preventDefault()
		$this = $(this)
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
		      dataType: "json"
		      cache: false
		      beforeSend:
		      	swal
		      		title: "<span class=\"fa fa-spinner fa-spin fa-3x\"></span>"
		      		text: "<h2>Syncronizing</h2>"
		      		html: true
		      		showConfirmButton: false
		      success: (response, data) ->
	        	swal 'Designations', "Synchronized", "success"
		      error: (response) ->
		        swal 'oops', 'Something went wrong'
		    false
		  else
		    swal 'Cancelled', '', 'error'
		  return

submitRatesForm = ->
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

$(document).on "page:change", ->
	syncingAllDesignations()
	submitRatesForm()
	getRates()