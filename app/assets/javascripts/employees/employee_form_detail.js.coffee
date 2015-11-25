class window.EmployeeFormDetail
  constructor: (elem) ->
    @elem = $(elem)

  addingClassToInputs: ->
    @elem.find("input[type='text']").addClass "form-control input-sm"
    @elem.find("select").addClass "form-control input-sm"
    @elem.find("textarea").addClass "form-control input-sm"

  getUnregisteredEmployeeParams: (elem) ->
    params = {
      employee_index: $.trim($(elem).data("employee-index"))
      month: $.trim($(elem).data("month"))
      year: $.trim($(elem).data("year"))
      project_id: $.trim($(elem).data("project-id"))
      employee_id: $.trim($(elem).data("employee-id"))
    }

    params

  employeeDateSelector: (date_elem, position = "bottom", type = "", format = "") ->
    if type == "year"
      mode = 2
    else
      mode = 0

    if format == ""
      format = 'mm/dd/yyyy'
      
    date_elem.datepicker(
      format: "#{format}"
      orientation: "#{position} left"
      minViewMode: mode
    ).on 'changeDate', (e) ->
       $(this).datepicker 'hide'

  employeeDesignationSelector: ->
    @elem.find("#emp_designation").select2
      placeholder: "--Select Designation--",
      allowClear: true

  @checkMaritalStatus: (elem) ->
    if $(elem).val() == "Married"
      $(".children_for_married_employee").fadeIn(300)
    else
      $(".children_for_married_employee").fadeOut(300)

  @closeEmployeeForm: (elem) =>
    self = $(elem)
    swal {
      title: 'Close Employee Form?'
      text: ''
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#DD6B55'
      confirmButtonText: 'Yes'
      closeOnConfirm: true
    }, ->
      self.closest(".modal").modal("hide")
      return

  @openEmployeeForm: (elem) ->  
    $this = $(elem)
    emp_form = new EmployeeFormDetail
    $.ajax
      type: $this.attr("method")
      url: $this.attr("action")
      data:
        emp_form.getUnregisteredEmployeeParams($this)
      cache: false
      beforeSend: ->
      success: (response, data) ->
        console.log "Status Ok"
      error: (response) ->
        swal 'oops', 'Something went wrong'

  validate: ->
    $self = @elem
    $self.find("form#new_employee_form").bootstrapValidator({
      feedbackIcons:
        valid: 'glyphicon glyphicon-ok'
        invalid: 'glyphicon glyphicon-remove'
        validating: 'glyphicon glyphicon-refresh'
      fields:
        first_name:
          validators: notEmpty: message: '* required'
        last_name:
          validators: notEmpty: message: '* required'
        gender:
          validators: notEmpty: message: '* required'
        marital_status:
          validators: notEmpty: message: '* required'
        date_of_birth:
          validators: 
            notEmpty: 
              message: '* required'
            date:
              format: "MM/DD/YYYY"
              message: "Not valid format"
        joining_date:
          validators: 
            notEmpty: 
              message: '* required'
            date:
              format: "MM/DD/YYYY"
              message: "Not valid format"
        cell_phone:
          validators: notEmpty: message: '* required'
        personal_email:
          validators: notEmpty: message: '* required'
        office_email:
          validators: notEmpty: message: '* required'
        nic:
          validators: 
            notEmpty: message: '* required'
        address:
          validators: notEmpty: message: '* required'
        home_phone:
          validators: notEmpty: message: '* required'
        ntn_no:
          validators: notEmpty: message: '* required'
        bank_account_no:
          validators: notEmpty: message: '* required'
        bank_name:
          validators: notEmpty: message: '* required'
        bank_branch:
          validators: notEmpty: message: '* required'
        medical_insurance:
          validators: notEmpty: message: '* required'
        conveyance:
          validators: notEmpty: message: '* required'
        gross_salary:
          validators: notEmpty: message: '* required'
        children:
          validators: notEmpty: message: '* required'
        is_internee:
          validators: notEmpty: message: '* required'
    }).on 'success.form.bv', (e) ->
      Employee.createEmployee()
    $('#employee_dob').on 'changeDate', (e) ->
      $self.find("form#new_employee_form").bootstrapValidator('revalidateField', 'date_of_birth')
    $('#emp_joining_date').on 'changeDate', (e) ->
      $self.find("form#new_employee_form").bootstrapValidator('revalidateField', 'joining_date')

    
