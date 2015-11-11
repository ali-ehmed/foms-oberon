openRecalculateForm = ->
	$("#recalculate_reports").on "click", ->
		$("#re_calculate_reports").modal("show")

window.closeForm = (elem) ->
  $this = $(elem)
  date_input = $this.closest("#re_calculate_reports").find("input#recalculate_month_and_year")
  date_input.removeAttr("style")
  if $("#calculate-report-error-msg").length
    $("#calculate-report-error-msg").remove()

recalculateReports = ->
  $('#calculate_reports_data').on 'click', ->
    $this = $(this)
    date_input = $this.closest('#re_calculate_reports').find('input#recalculate_month_and_year')
    month_param = date_input.val().split('-')[0]
    year_param = date_input.val().split('-')[1]
    if date_input.val() == ''
      date_input.css 'border', '1px solid #D4220F'
      date_input.after '<p id="calculate-report-error-msg">Date can\'t be blank?</p>' unless $('#calculate-report-error-msg').length
    else
      closeForm $this
      return $.ajax(
        type: 'POST'
        url: $this.closest('#re_calculate_reports').data('url')
        data:
          month: $.trim(month_param)
          year: $.trim(year_param)
        dataType: 'json'
        cache: false
        beforeSend: swal(
          title: '<span class="fa fa-spinner fa-spin fa-3x"></span>'
          text: '<h2>Caluculating...</h2>'
          html: true
          showConfirmButton: false)
        success: (response, data) ->
          if response.status == 'created'
            swal(
              title: 'Successfully Saved'
              text: "Note: This report was calculated at Dollar rate <strong>#{response.dollar_rate}</strong>"
              html: true
              type: 'info'
            )
            $this.closest('#re_calculate_reports').modal('hide')
            date_input.val('')
          else
            swal 'Please Check the following error', response.error_message, 'error'
        error: (response) ->
          swal 'oops', 'Something went wrong'
      )
    return

$(document).on "page:change", ->
  openRecalculateForm()
  recalculateReports()

  $('#recalculate_month_and_year').datepicker(
      format: 'm - yyyy'
      orientation: 'bottom left'
      minViewMode: 1
  	).on 'changeDate', (e) ->
    	$(this).datepicker 'hide'

