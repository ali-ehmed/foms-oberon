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
    $("#projects_reports_tab").addClass "in active"
    $("#reports_tab li:first-child").addClass "active"
    $this = $(this)
    $.ajax
      type: 'Get'
      url: $this.data("url")
      cache: false
      success: (response, data) ->
        console.log "Status: Ok"
      error: (response) ->
        swal 'oops', 'Something went wrong'

  $('#reports_tab li a').on 'click', (e) ->
    # e.preventDefault()
    $.ajax
      type: 'Get'
      url: "/reports/profitability_reports.js"
      cache: false
      success: (response, data) ->
        console.log "Status: Ok"
      error: (response) ->
        swal 'oops', 'Something went wrong'

  $('#reports_tab a').click (e) ->
    e.preventDefault()
    $(this).tab 'show'
    return

  $('#profitability_report_modal').on 'hidden.bs.modal', ->
    $("#report_search").find("input[type='text']").val("")
    $("#reports_tab li").removeClass "active" #Remove Active Tab

    $(".projects_reports").empty()
    $(".projects_reports").closest("#projects_reports_tab").removeClass "in active"

    $(".employees_reports").empty()
    $(".employees_reports").closest("#employee_reports_tab").removeClass "in active"

    $("#view_full_profitability_report").removeClass 'active-list'

  $(document).on "click", '#getReports', (e) ->

    $form = $(this).closest("form")
    $activeElem = $('#profitability_report_modal').find('#reports_tab li')
    $form_data = $form.serializeArray()
    if $activeElem.first().hasClass('active')
      $form_data.push
        name: 'profit_report'
        value: 'true'
    else
      $form_data.push
        name: 'profit_report'
        value: 'false'
    e.preventDefault()
    $search_btn = $form.find('input[type=\'submit\']')
    $.ajax
      type: $form.attr('method')
      url: $form.attr('action')
      data: $form_data
      cache: false
      beforeSend: ->
        $search_btn.replaceWith '<button id=\'prof_report_loader_btn\' class="btn btn-danger">Searching... <i class="fa fa-spinner fa-spin"></i></button>'
      success: (response, data) ->
        console.log 'Status: Ok'
        $('#prof_report_loader_btn').replaceWith $search_btn
        return
      error: (response) ->
        $('#prof_report_loader_btn').replaceWith $search_btn
        swal 'oops', 'Something went wrong'



    