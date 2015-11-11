$(document).on 'page:change', ->
  $('#report_month_year').datepicker(
      format: 'm - yyyy'
      orientation: 'bottom left'
      minViewMode: 1
  	).on 'changeDate', (e) ->
    	$(this).datepicker 'hide'
  
  $('#report_project_id').select2
    placeholder: 'Choose Project'
    allowClear: true
    
  $('#report_year').datepicker(
      format: 'yyyy'
      orientation: 'bottom left'
      minViewMode: 2
    ).on 'changeDate', (e) ->
      $(this).datepicker 'hide'

  $('#start_date').datepicker(
      format: 'M dd, yyyy'
      orientation: 'bottom left'
      todayHighlight: true
    ).on 'changeDate', (e) ->
      $(this).datepicker 'hide'

  $('#end_date').datepicker(
      format: 'M dd, yyyy'
      orientation: 'bottom left'
      todayHighlight: true
    ).on 'changeDate', (e) ->
      $(this).datepicker 'hide'

  $(".employee_history_report_table").DataTable
    responsive: true
    bSort: true
    bFilter: true
    "iDisplayLength": 7

  $("#view_full_profitability_report").on "click", ->
    $(this).addClass 'active-list'
    $('#profitability_report_modal').modal("show")

  $('#profitability_report_modal').on 'shown.bs.modal', ->
    $this = $(this)
    $.ajax
      type: 'Get'
      url: $this.data("url")
      cache: false
      success: (response, data) ->
        console.log "Status: Ok"
      error: (response) ->
        swal 'oops', 'Something went wrong'

  $('#profitability_report_modal').on 'hidden.bs.modal', ->
    $("#full_prof_report").empty()
    $("#view_full_profitability_report").removeClass 'active-list'


    