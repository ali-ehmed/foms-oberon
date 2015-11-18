$invoices =
  init: ->
    ### Initializing Methods ###
    $invoices.getInvoiceNumber()
    $invoices.fetchingCurrentInvoices()
    $invoices.addCustomInvoiceForm()
    $invoices.removeCustomInvoiceForm()
    $invoices.savingCustomInvoice()

    return

  getInvoiceNumber: ->
    $input = $('input[name=\'no_of_days\']')
    url = $input.data('invoice-no-url')
    $.get url, (response) ->
      $input.val response.invoice_number
      return

  getInvoiceParams: ->
    date_input = $('input#invoice_month_year')
    month_param = date_input.val().split('-')[0]
    year_param = date_input.val().split('-')[1]
    project_param = $("#invoice_projects").val()

    params = {
      month: $.trim(month_param)
      year: $.trim(year_param)
      invoice_project: project_param
    }

    return params

  fetchingCurrentInvoices: ->
    $("#fetch_invoices_btn").on 'click', ->
      $elem = $(this)
      method = $elem.data("method")
      url = $elem.data("action")

      employee_id = $("#invoice_employees").val()
      params = $invoices.getInvoiceParams()

      params["invoice_employee"] = employee_id if employee_id

      $btn_html = $elem.html()
      $.ajax
        type: method
        url: url
        data: params
        cache: false
        beforeSend: ->
          $elem.html("<i class=\"fa fa-spinner fa-pulse\"></i> <strong>Fetching</strong>")
        success: (response, data) ->
          if response.status == 'error'
            swal
              title: 'Couldn\'t Fetch Invoices'
              text: response.message
              type: 'error'
              html: true
          else
            console.log "Status OK"
          $elem.html($btn_html)
        error: (response) ->
          swal 'oops', 'Something went wrong'
          $elem.html($btn_html)

  synchronizeInvoicesFromRm: (elem, text = "") ->
    $this = $(elem)
    date_input = $('input#invoice_month_year')
    month_param = date_input.val().split('-')[0]
    year_param = date_input.val().split('-')[1]
    no_of_days = $('#no_of_days').val()
    project_id = $("#invoice_projects").val()

    params = $invoices.getInvoiceParams()
    params["no_of_days"] = no_of_days

    # If Project based sync
    if $this.data("isproject") == false
      delete params["invoice_project"]

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

  sumAndGetTotal: (elem, for_field, add_less_amount = "") ->
    $elem = $(elem)
    switch for_field
      when "hours"
        total_hours = 0

        hours = []
        hours.push $elem.val()

        $(".invoice_hours").each ->
          value = $(this).find("a span").html()
          if $.isNumeric value
            hours.push value

        _.each hours, (val) ->
          total_hours += parseFloat(val)

        $("#invoice_total_hours").text total_hours.toFixed(1)

        # return total_hours.toFixed(1)

      when "amount"
        total_amount = 0

        elem_value = $elem.val()
        elem_value = -Math.abs(elem_value) if add_less_amount == "less" # For new custom invoice

        amount = []
        amount.push elem_value

        $(".invoice_amount").each ->
          value = $(this).find("a span").html()
          if $.isNumeric value
            amount.push value

        _.each amount, (val) ->
          total_amount += parseFloat(val)

        $("#invoice_total_amount").text total_amount.toFixed(1)

        # return total_amount.toFixed(1)

  getHtmlForNewInvoice: ->
    html = 
      "<tr id='inline_invoice_form'>
        <td>
          <a href='#' class='text-danger' data-toggle='tooltip' data-placement='top' title='Remove' id='remove_added_invoice'>
            <i class='fa fa-minus-square-o fa-2x remove_invoice_btn'></i>
          </a>
        </td>
        <td>---</td>
        <td>---</td>
        <td>---</td>
        <td>
          <select class='form-control' id='add_less_select'>
            <option value='add'>Add</option>
            <option value='less'>Less</option>
          </select>
        </td>
        <td>
          <textarea class='form-control' placeholder='Description' rows='3' cols='50' id='new_description' name='new_description'></textarea>
        </td>
        <td>---</td>
        <td>---</td>
        <td>
          <input class='form-control' value='0' id='new_amount'/>
        </td>
        <td>
          <a href='#' class='text-danger' data-url='/invoices/custom_invoice.json' data-toggle='tooltip' data-placement='top' title='Save' id='save_added_invoice'>
            <i class='fa fa-check fa-2x save_invoice_btn'></i>
          </a>
        </td>
      </tr>"

    html


  removeCustomInvoiceForm: ->
    $(document).on "click", "#remove_added_invoice", (e) ->
      e.preventDefault()
      setTimeout ->
        $('[data-toggle="tooltip"]').tooltip()
      , 200

      $this = $(this)
      if $this.closest("#inline_invoice_form").length
        row = $this.closest("#inline_invoice_form")
        row.remove()

  addCustomInvoiceForm: ->
    $(document).on "click", "#add_inline_invoice_btn", (e) ->
      e.preventDefault()
      setTimeout ->
        $('[data-toggle="tooltip"]').tooltip()
      , 200

      $this = $(this)
      unless $("#inline_invoice_form").length
        $('tr.all_invoices').last().after($invoices.getHtmlForNewInvoice)

  savingCustomInvoice: ->
    $(document).on "click", "#save_added_invoice", (e) ->
      e.preventDefault()
      $this = $(this)
      $new_amount_elem = $("#new_amount")
      $add_less_amount = $("#add_less_select").val()
      url = $this.data("url")

      params = $invoices.getInvoiceParams()      
      params["description"] = $("textarea[name='new_description']").val()
      params["is_adjustment"] = true

      if $add_less_amount == "less"
        params["amount"] = -Math.abs($add_less_amount)

      params["amount"] = $new_amount_elem.val()
      params["add_less"] = $add_less_amount

      $.ajax
        type: "Post"
        url: url
        data: params
        cache: false
        beforeSend: ->
          swal
            title: '<i class=\"fa fa-spinner fa-pulse fa-3x\"></i>'
            text: "Saving Invoice"
            type: 'info'
            html: true
            showConfirmButton: false
        success: (response, data) ->
          swal "Saved Successfully", "", "success"
          # $invoices.sumAndGetTotal($new_amount_elem, "amount", $add_less_amount)
          $("#fetch_invoices_btn").trigger("click")
        error: (response) ->
          swal 'Oops', 'Something went wrong'



window.syncInvoices = (elem, text = "") ->
	$invoices.synchronizeInvoicesFromRm(elem, text)

window.calculateTotalData = (elem, for_field) ->
  $invoices.sumAndGetTotal(elem, for_field)

$(document).on "page:change", ->
  $invoices.init()
  
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
        $("#invoice_projects").val("")
        $("#invoice_projects_select .select2-selection__rendered").html("<span class=\"select2-selection__placeholder\">--Select Project--</span>")

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
        $("#invoice_employees").val("")
        $("#invoice_employees_select .select2-selection__rendered").html("<span class=\"select2-selection__placeholder\">--Select Employee--</span>")

        $("#invoice_employees_select").slideUp(500).fadeTo 500, 0, ->
          $(this).hide()
      else
        $("#invoice_employees_select").slideDown(500).fadeTo 0, 500, ->
          $(this).show()
  )

