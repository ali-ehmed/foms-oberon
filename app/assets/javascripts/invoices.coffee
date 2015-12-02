### Invoices ###
$invoices =
  init: ->
    ### Initializing Methods ###
    $invoices.getInvoiceNumber()
    $invoices.fetchingCurrentInvoices()
    $invoices.addCustomInvoiceForm()
    $invoices.removeCustomInvoiceForm()
    $invoices.savingCustomInvoice()
    $invoices.generatingTotalInvoices()

    return

  getInvoiceNumber: (params = "")->
    $input = $('input[name=\'no_of_days\']')
    url = $input.data('invoice-no-url')
    $.get url, params, (response) ->
      $input.val response.invoice_number
      window.old_no_of_days = "#{response.invoice_number}" # Setting No of days for dynamic change of values
      window.old_no_of_days_before_fetch = "#{response.invoice_number}" #Helper variable to prevent fetching of Invoice Number after every fetch btn trigger
      return

  getInvoiceParams: ->
    date_input = $('input#invoice_month_year')
    month_param = date_input.val().split('-')[0]
    year_param = date_input.val().split('-')[1]
    project_param = $("#invoice_projects").val()

    curr_date = new Date
    get_curr_month = curr_date.getMonth()
    get_curr_year = curr_date.getFullYear()

    month_param ?= get_curr_month
    year_param ?= get_curr_year

    params = {
      month: $.trim(month_param)
      year: $.trim(year_param)
      invoice_project: project_param
    }

    return params

  submitFetching: ->
    $("#fetch_invoices_btn").trigger("click")

  fetchingCurrentInvoices: ->
    $("#fetch_invoices_btn").on 'click', ->
      $elem = $(this)
      method = $elem.data("method")
      url = $elem.data("action")

      employee_id = $("#invoice_employees").val()
      $_params = $invoices.getInvoiceParams()

      $_params["invoice_employee"] = employee_id if employee_id

      $btn_html = $elem.html()
      $.ajax
        type: method
        url: url
        data: $_params
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
            console.log "Invoices Fetched"
            ## Checking Resyncing Data ##
            $invoices.get_resync_status($_params)

            ## Getting Invoice Number ##
            $invoices.getInvoiceNumber($_params) if $("#no_of_days").val() == window.old_no_of_days_before_fetch
          $elem.html($btn_html)
        error: (response) ->
          swal 'oops', 'Something went wrong'
          $elem.html($btn_html)
        complete: ->
          window.old_no_of_days_before_fetch = window.old_no_of_days

  get_resync_status: (_params_) ->
    $.ajax
      type: "get"
      url: "/invoices/resync_status"
      data: _params_
      cache: false
      dataType: "json"
      success: (response, data) ->
        if response.status == true
          swal
            title: 'Update Required'
            text: response.message
            type: 'info'
            html: true
        else if response.status == "error"
          swal 'Error Occur!', "#{response.message}", "error"
        else
          console.log "Status false, no resync required"
      error: (response) ->
        swal 'Oops!', 'Something went wrong'

  synchronizeInvoicesFromRm: (elem, text = "") ->
    $this = $(elem)

    no_of_days = $('#no_of_days').val()

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
            when 'synced_skiped'
              swal
                title: "Rates are missing:"
                text: response.message
                html: true
                type: "warning"
            else
              swal
              	title: 'Synchronization Completed'
              	text: "#{response.message}"
              	type: 'success'
              	html: true
              $invoices.submitFetching() if $this.data("isproject") == true #Submit Button
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

      when "amount"
        total_amount = 0

        elem_value = $elem.val()

        amount = []
        amount.push elem_value

        $(".invoice_amount").each ->
          value = $(this).find("a span").html()
          if $.isNumeric value
            amount.push value

        _.each amount, (val) ->
          total_amount += parseFloat(val)

        $("#invoice_total_amount").text total_amount.toFixed(1)

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
        $("#add_inline_invoice_btn").removeClass("btn btn-link disabled") #Enabling disabled link

  addCustomInvoiceForm: ->
    $(document).on "click", "#add_inline_invoice_btn", (e) ->
      e.preventDefault()
      setTimeout ->
        $('[data-toggle="tooltip"]').tooltip()
      , 200

      $this = $(this)
      unless $("#inline_invoice_form").length
        $this.closest("#add_new_invoice").before("#{$invoices.getHtmlForNewInvoice}")
        $this.addClass("btn btn-link disabled") #Disabling Link to avoid repetition

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

      params["amount"] = $new_amount_elem.val()

      if $add_less_amount == "less"
        params["amount"] = -Math.abs($new_amount_elem.val())

      params["add_less"] = $add_less_amount

      $.ajax
        type: "Post"
        url: url
        data: params
        cache: false
        beforeSend: ->
          $this.addClass("btn btn-link disabled")
          swal
            title: '<i class=\"fa fa-spinner fa-pulse fa-3x\"></i>'
            text: "Saving Invoice"
            type: 'info'
            html: true
            showConfirmButton: false
        success: (response, data) ->
          swal "Saved Successfully", "", "success"
          $invoices.submitFetching() #Submit Button
        error: (response) ->
          swal 'Oops', 'Something went wrong'
        complete: ->
          $this.removeClass("btn btn-link disabled")

  generatingTotalInvoices: ->
    $(document).on "click", "#generate_invoices", (e) ->
      e.preventDefault()
      $this = $(this)
      params = $invoices.getInvoiceParams()

      ## Validate Invoice Number
      if $invoices.validateInvoiceNumber() == true
        false
      else
        params["invoice_no"] = $("#invoice_no").val()
        params["invoice_sent_date"] = $("#invoice_date").val()
        params["pkr_and_dollar"] = $("#pkr_and_dollar").val()
        params["payment_terms"] = $("#payment_terms").val()

        swal {
          title: "Generate These Invoices?"
          type: 'info'
          showCancelButton: true
          confirmButtonColor: 'rgb(221, 107, 85) !important;'
          confirmButtonText: 'Sure!'
          closeOnConfirm: false
        }, ->
          $.ajax
            type: $this.data("method")
            url: $this.data("action")
            data: params
            cache: false
            dataType: "json"
            beforeSend: ->
              swal
                title: '<i class=\"fa fa-spinner fa-pulse fa-3x\"></i>'
                text: "Generating Total Invoices"
                type: 'info'
                html: true
                showConfirmButton: false
            success: (response, data) ->
              if response.status == "error"
                swal "#{response.message}", "Please contact your developer", "error"
              else
                swal "Successfully", "#{response.message}", "success"
                $invoices.submitInvoicePdfGenerateForm("#{response.invoice_created_date}")
            error: (response) ->
              swal 'Oops', 'Something went wrong'
            complete: ->
              $("#fetch_invoices_btn").trigger("click")

  
  validateInvoiceNumber: ->
    $invoice_no = $("#invoice_no")
    $invoice_date = $("#invoice_date")

    if $invoice_date.val() == ""
      $invoice_date.closest(".form-group").addClass "has-warning"
      unless $invoice_date.closest(".form-group").find(".invoice_error").text()
        $invoice_date.closest(".form-group").find(".invoice_error").append("* Please set the invoice date").show()
      true
    else
      $invoice_date.closest(".form-group").removeClass "has-warning"
      $invoice_date.next().empty().hide()

      if $invoice_no.val() == ""
        $invoice_no.closest(".form-group").addClass "has-warning"
        unless $invoice_no.closest(".form-group").find(".invoice_error").text()
          $invoice_no.closest(".form-group").find(".invoice_error").append("* Please set the invoice number").show()
        true
      else
        $invoice_no.closest(".form-group").removeClass "has-warning"
        $invoice_no.next().empty().hide()
        false

  submitInvoicePdfGenerateForm: (invoice_created_date) ->
    $form = $("#invoices_pdf_generate_form")
    action = $form.attr("action")
    action = "invoices/#{invoice_created_date}"
    $form.attr "action", "#{action}"
    $form.submit()

  validateTotalNoOfDays: (input) ->
    if input.val() == ""
      $.purrAlert '',
        html: true
        text: "Total No Of Days Cannot be null"
        text_bold: true

      input.val(window.old_no_of_days)
      return false

    if input.val() > 31 or input.val() < 1
      $.purrAlert '',
        html: true
        text: "Invalid No of Days"
        text_bold: true
      return false

  getRecalculateFields: (count) ->
    _fields_ = {
      id: $(".id_params_#{count}").data("invoice-id")
      description: $(".description_params_#{count} a span")
      is_hourly: $(".is_hourly_params_#{count}")
      rates: $(".rates_params_#{count} a span")
      hours: $(".hours_params_#{count} a span")
      percent_billing: $(".percent_billing_params_#{count} a span")
      worked_days: $(".worked_days_#{count} a span")
      unpaid_leaves: $(".unpaid_leaves_#{count} a span")
      amount: $(".amount_params_#{count} a span")
    }
    _fields_

  recalculate: (params, total_no_of_days, alert = false) ->
    $table = $("#invoices_table")
    if $table.length
      $.ajax
        type: "Put"
        url: "/invoices/recalculate"
        data: { invoice_params: params}
        cache: false
        dataType: "json"
        success: (response, data) ->
          console.log
          setTimeout(->
            $("#fetch_invoices_btn").trigger("click")
            unless alert == false
              $.purrAlert '',
                html: true
                text: "No of days changed all amounts are Recalculated"
                text_bold: true
                purr_type: "warning"
          , 50)
        error: (response) ->
          swal 'Oops', 'Something went wrong'
    else
      $("#fetch_invoices_btn").trigger("click")

    window.old_no_of_days = total_no_of_days

window.isDate =  (val) ->
    date = new Date(val);
    return !isNaN date.valueOf() 

window.syncInvoices = (elem, text = "") ->
	$invoices.synchronizeInvoicesFromRm(elem, text)

window.calculateTotalData = (elem, for_field) ->
  $invoices.sumAndGetTotal(elem, for_field)

window.isShadowCompatibility = (elem, object) ->
  $this = $(elem)
  value = $this.find("span").html()
  if object["IsAdjustment"] == false
    if object["IsShadow"] == true
      $.purrAlert '',
        html: true
        text: "<strong>This Record is not editable</strong>"
        type: "error"
      return false

window.recalculateAmount = (elem) ->
  $this = $(elem)
  $total_no_of_days = $this
  calculate = new Calculations

  unless $this.val() == window.old_no_of_days
    count = 1
    params = {}
    current_invoices = []
    while count <= $("#count_index_invoice").data("count-index")
      $id = $(".id_params_#{count}").data("invoice-id")
      $is_hourly = $(".is_hourly_params_#{count}")
      $rates = $(".rates_params_#{count} a span")
      $percent_billing = $(".percent_billing_params_#{count} a span")
      $worked_days = $(".worked_days_#{count} a span")
      $unpaid_leaves = $(".unpaid_leaves_#{count} a span")

      $amount = $(".amount_params_#{count} a span")

      if $amount.length
        if $is_hourly.val() == "false"
          if $rates.length
            recalculateAmount = calculate.nonHourlyAmount($rates.html(), $percent_billing.html(), $worked_days.html(), $total_no_of_days.val(), $unpaid_leaves.html())
            # recalculateAmount = ((parseFloat($rates.html()) * parseFloat($percent_billing.html())) / 100) * ((parseInt($worked_days.html()) / $total_no_of_days.val())) - (((parseFloat($unpaid_leaves.html()) * parseFloat($rates.html()) * parseFloat($percent_billing.html())) / 100) / $total_no_of_days.val())
            $amount.html(recalculateAmount)

        $roundAmount = Math.round(parseFloat($amount.html()) * 100) / 100
        $amount.html($roundAmount)

      params = {}
      params["id"] = $id
      params["amount"] = $roundAmount
      current_invoices.push(params)

      count++

    $invoices.recalculate(current_invoices, $this.val(), true) #Updating

window.updateAmount = (elem, field_name, count) ->
  $total_no_of_days = $("#no_of_days")
  calculate = new Calculations
  
  $invoices.validateTotalNoOfDays($total_no_of_days) #Validating No of Days Input

  params = {}
  current_invoices = []
  
  $fields = $invoices.getRecalculateFields(count)
  $this = $(elem)

  switch field_name
    when 'rates'
      console.log "For Rates"
      $rates = $this.val()
      $worked_days = $fields["worked_days"].html()
      $unpaid_leaves = $fields["unpaid_leaves"].html()
      $hours = $fields["hours"].html()
    when "no_of_days"
      console.log "For Days"
      $rates = $fields["rates"].html()
      $worked_days = $this.val()
      $unpaid_leaves = $fields["unpaid_leaves"].html()
      $hours = $fields["hours"].html()
    when "unpaid_leaves"
      console.log "For Leaves"
      $rates = $fields["rates"].html()
      $worked_days = $fields["worked_days"].html()
      $unpaid_leaves = $this.val()
      $hours = $fields["hours"].html()
    when "hours"
      console.log "For Hours"
      $hours = $this.val()
      $unpaid_leaves = $fields["unpaid_leaves"].html()
      $worked_days = $fields["worked_days"].html()
      $rates = $fields["rates"].html()

  defaultRatesValue = parseFloat($rates)

  if $fields["is_hourly"].val() == "true"
    recalculateAmount = calculate.hourlyAmount($rates, $hours) #Calculating Hourly Amount
    $fields["amount"].html(recalculateAmount)
  else
    #Calculating Nonhourly Amount
    recalculateAmount = calculate.nonHourlyAmount($rates, $fields["percent_billing"].html(), $worked_days, $total_no_of_days.val(), $unpaid_leaves)
    
    console.log "---updateAmount---"
    console.log $rates
    console.log $fields["percent_billing"].html()
    console.log $worked_days
    console.log $unpaid_leaves

    $fields["amount"].html(recalculateAmount)

  $roundAmount = Math.round(parseFloat($fields["amount"].html()) * 100) / 100
  $fields["amount"].html($roundAmount)

  if $fields["description"].length
    temp_description = $fields["description"].html().replace(String(defaultRatesValue), $fields["rates"].html())
    $fields["description"].html(temp_description)

  params = {}
  params["id"] = $fields["id"]
  params["description"] = temp_description
  params["amount"] = $roundAmount
  current_invoices.push(params)

  $invoices.recalculate(current_invoices, $total_no_of_days.val(), false) #Updating

window.updateRates = (elem, count) ->
  $total_no_of_days = $("#no_of_days")
  $amount = $(elem)
  calculate = new Calculations

  $invoices.validateTotalNoOfDays($total_no_of_days) #Validating No of Days Input

  params = {}
  current_invoices = []

  $fields = $invoices.getRecalculateFields(count)

  defaultRatesValue = parseFloat($fields["rates"].html())

  if $fields["is_hourly"].val() == "true"
    calculatedRates = calculate.hourlyRates($amount.val(), $fields["hours"].html()) #Calculating Hourly Rates
    $fields["rates"].html(calculatedRates)
  else
    #Calculating Nonhourly Rates
    calculatedRates = calculate.nonHourlyRates($amount.val(), $total_no_of_days.val(), $fields["worked_days"].html(), $fields["percent_billing"].html())
    $fields["rates"].html(calculatedRates)
    console.log "---updateRates---"
    console.log calculatedRates
  $roundedRates = Math.round(parseFloat($fields["rates"].html()) * 100) / 100
  $fields["rates"].html($roundedRates)

  if $fields["description"].length
    temp_description = $fields["description"].html().replace(String(defaultRatesValue), $fields["rates"].html())
    $fields["description"].html(temp_description)

  params = {}
  params["id"] = $fields["id"]
  params["description"] = temp_description
  params["rates"] = $roundedRates
  current_invoices.push(params)

  $invoices.recalculate(current_invoices, $total_no_of_days.val(), false) #Updating

window.getCurrencyLabel = (elem) ->
  $this = $(elem)
  $("span.currency_label").html($this.val())


$(document).on "page:change", ->
  ### Initializing Invoices Coffee Script ###
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

  $(".bootstrap-touchspin-down").attr("onclick", "recalculateAmount($('#no_of_days'));")
  $(".bootstrap-touchspin-up").attr("onclick", "recalculateAmount($('#no_of_days'));")
  
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

