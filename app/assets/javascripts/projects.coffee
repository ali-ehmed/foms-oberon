syncingAllProjects = ->
	$("#sync_all_projects").on "click", (e) ->
		e.preventDefault()
		$this = $(this)
		swal {
		  title: "Sync All Projects?"
		  type: 'info'
		  showCancelButton: true
		  confirmButtonText: 'Sync All Projects'
		  cancelButtonText: 'Cancel'
		  closeOnConfirm: false
		  closeOnCancel: true
		  showLoaderOnConfirm: true
		}, ->
	    $.ajax
	      type: 'Get'
	      url: $this.data("url")
	      dataType: "json"
	      cache: false
	      success: (response, data) ->
        	swal 'Projects', "Synchronized", "success"
        	$(".rm_projects_table").DataTable().ajax.url("/projects/sync_projects.json").load()
	      error: (response) ->
	        swal 'oops', 'Something went wrong'
	    false
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
	  
	