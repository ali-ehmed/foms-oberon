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