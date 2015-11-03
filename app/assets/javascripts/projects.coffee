syncingAllProjects = ->
	$("#sync_all_projects").on "click", (e) ->
		e.preventDefault()
		$this = $(this)
		swal {
		  title: "Sync All Projects?"
		  type: 'warning'
		  showCancelButton: true
		  confirmButtonColor: '#DD6B55'
		  confirmButtonText: 'Sync All Projects'
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
	        	swal 'Projects', "Synchronized", "success"
	        	$(".rm_projects_table").DataTable().ajax.url("/projects/sync_projects.json").load()
		      error: (response) ->
		        swal 'oops', 'Something went wrong'
		    false
		  else
		    swal 'Cancelled', '', 'error'
		  return
		
		

$(document).on "page:change", ->
	syncingAllProjects()

	$(".rm_projects_table").DataTable
	  responsive: true
	  bSort: true
	  bFilter: true
	  ajax: $(".rm_projects_table").data("source")
  	"columns": [
  		{"data" : "project_id"}
  		{"data" : "name"}
  		{"data" : "status"}
  		{"data" : "customer_name"}
  		{"data" : "customer_address"}
  		{"data" : "customer_personal_email"}
  		{"data" : "customer_invoice_email"}
  		{"data" : "director_name"}
		]
	  
	