# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151029070804) do

  create_table "accrualbonusdetails", primary_key: "Tenure", force: :cascade do |t|
    t.float "Percentage", limit: 53, null: false
  end

  create_table "authenticates", force: :cascade do |t|
    t.string "Password",   limit: 45,  default: "",  null: false
    t.string "role",       limit: 255
    t.string "rm_user_id", limit: 6,   default: "0"
  end

  add_index "authenticates", ["rm_user_id"], name: "rm_user_id", using: :btree

  create_table "bonushistories", primary_key: "idbonushistory", force: :cascade do |t|
    t.string  "EmployeeID", limit: 6
    t.integer "month",      limit: 4
    t.integer "year",       limit: 4
    t.float   "amount",     limit: 53
  end

  create_table "consultants", force: :cascade do |t|
    t.integer "employee_id", limit: 4
    t.integer "month",       limit: 4
    t.integer "year",        limit: 4
    t.float   "cogs",        limit: 24
    t.float   "opex",        limit: 24
  end

  add_index "consultants", ["id"], name: "id", using: :btree

  create_table "conveyanceallowances", id: false, force: :cascade do |t|
    t.integer  "ConveyanceAllowance", limit: 4, null: false
    t.datetime "UpdationDate",                  null: false
  end

  create_table "conveyancepolicy", force: :cascade do |t|
    t.string "type",        limit: 40
    t.string "description", limit: 100
    t.float  "allowance",   limit: 53
  end

  create_table "current_invoice_initiation_details", id: false, force: :cascade do |t|
    t.integer "id",         limit: 4, null: false
    t.integer "project_id", limit: 4, null: false
    t.integer "month",      limit: 4
    t.integer "year",       limit: 4
  end

  add_index "current_invoice_initiation_details", ["id"], name: "id", using: :btree

  create_table "current_invoice_initiation_headings", id: false, force: :cascade do |t|
    t.integer "id",                                    limit: 4,  null: false
    t.integer "main_heading_id",                       limit: 4
    t.string  "heading",                               limit: 25
    t.integer "level",                                 limit: 4
    t.integer "parent_id",                             limit: 4
    t.integer "current_invoice_initiation_details_id", limit: 4
  end

  add_index "current_invoice_initiation_headings", ["id"], name: "id", using: :btree

  create_table "current_invoice_initiations", id: false, force: :cascade do |t|
    t.integer "id",                                     limit: 4,  null: false
    t.float   "amount",                                 limit: 24
    t.string  "description",                            limit: 50
    t.integer "current_invoice_initiation_headings_id", limit: 4
  end

  add_index "current_invoice_initiations", ["id"], name: "id", using: :btree

  create_table "current_invoices", force: :cascade do |t|
    t.integer "project_id",       limit: 4,                    null: false
    t.string  "employee_id",      limit: 255,  default: ""
    t.boolean "ishourly"
    t.float   "hours",            limit: 24
    t.float   "rates",            limit: 53
    t.float   "amount",           limit: 53
    t.string  "month",            limit: 255
    t.string  "year",             limit: 255
    t.string  "description",      limit: 1000
    t.float   "percent_billing",  limit: 24
    t.string  "project_name",     limit: 255
    t.string  "employee_name",    limit: 255
    t.string  "email",            limit: 100
    t.boolean "IsShadow",                      default: false
    t.date    "start_date"
    t.date    "end_date"
    t.integer "no_of_days",       limit: 4,    default: 0
    t.float   "percentage_alloc", limit: 24
    t.boolean "IsAdjustment",                  default: false
    t.boolean "add_less",                      default: true
    t.float   "leaves",           limit: 53,   default: 0.0
    t.float   "unpaid_leaves",    limit: 53,   default: 0.0
    t.float   "accrued_leaves",   limit: 53,   default: 0.0
    t.float   "balance_leaves",   limit: 53,   default: 0.0
    t.string  "task_notes",       limit: 500
    t.binary  "reminder",         limit: 500
  end

  create_table "designations", primary_key: "designation_id", force: :cascade do |t|
    t.string "designation", limit: 255
  end

  create_table "divisions", id: false, force: :cascade do |t|
    t.integer "id",        limit: 4
    t.string  "div_name",  limit: 255
    t.string  "div_owner", limit: 255
  end

  create_table "dollar_rates", force: :cascade do |t|
    t.integer "month",       limit: 4
    t.integer "year",        limit: 4
    t.float   "dollar_rate", limit: 24
  end

  create_table "dummy", id: false, force: :cascade do |t|
    t.string "field1", limit: 5
    t.string "field2", limit: 60
  end

  create_table "educationdetails", primary_key: "EducationDetailID", force: :cascade do |t|
    t.string  "EmployeeID",    limit: 6,  default: "",       null: false
    t.string  "Qualification", limit: 45, default: "",       null: false
    t.string  "Institute",     limit: 45, default: "",       null: false
    t.integer "YearFrom",      limit: 4,                     null: false
    t.integer "YearTo",        limit: 4,                     null: false
    t.string  "Type",          limit: 45, default: "Degree", null: false
  end

  create_table "employee_allocations", force: :cascade do |t|
    t.integer  "rm_project_id",    limit: 4,                  null: false
    t.string   "EmployeeID",       limit: 6,  default: "",    null: false
    t.datetime "start_date",                                  null: false
    t.datetime "end_date",                                    null: false
    t.integer  "percentage",       limit: 4,  default: 0
    t.float    "hours",            limit: 24, default: 0.0
    t.float    "hour_based_rates", limit: 53, default: 0.0
    t.float    "team_based_rates", limit: 53, default: 0.0
    t.string   "created_by",       limit: 45
    t.string   "last_updated_by",  limit: 45
    t.string   "month",            limit: 45
    t.integer  "year",             limit: 4
    t.boolean  "ishourly",                    default: true,  null: false
    t.boolean  "islocked",                    default: false
    t.float    "Amount",           limit: 24, default: 0.0
  end

  add_index "employee_allocations", ["EmployeeID"], name: "EmployeeID", using: :btree
  add_index "employee_allocations", ["rm_project_id"], name: "project_id", using: :btree

  create_table "employee_profitibility_reports", force: :cascade do |t|
    t.string  "employee_id",         limit: 255, default: "", null: false
    t.string  "employee_name",       limit: 255, default: "", null: false
    t.float   "compensation",        limit: 24
    t.float   "operational_expense", limit: 24
    t.float   "total",               limit: 24
    t.float   "invoice_amount",      limit: 24
    t.float   "profit",              limit: 24
    t.integer "month",               limit: 4
    t.integer "year",                limit: 4
  end

  create_table "employeeaccrualbonus", primary_key: "EmployeeAccrualID", force: :cascade do |t|
    t.string  "EmployeeID", limit: 6,  default: "", null: false
    t.integer "Month",      limit: 4,               null: false
    t.integer "Year",       limit: 4,               null: false
    t.float   "Amount",     limit: 53,              null: false
  end

  create_table "employeeaccrualbonuspaids", primary_key: "IDAccrualBonusPaid", force: :cascade do |t|
    t.string  "EmployeeID", limit: 6,  default: "", null: false
    t.integer "Month",      limit: 4,               null: false
    t.integer "Year",       limit: 4,               null: false
    t.float   "Amount",     limit: 53,              null: false
  end

  create_table "employeebalances", force: :cascade do |t|
    t.string "EmployeeID", limit: 6
    t.float  "medical",    limit: 53
    t.float  "bonus",      limit: 53
    t.float  "salary",     limit: 53
    t.float  "tax",        limit: 53
    t.float  "accrual",    limit: 53
  end

  create_table "employeebankaccountdetails", primary_key: "EmployeeID", force: :cascade do |t|
    t.string "BankAccountNo", limit: 45, default: "", null: false
    t.string "BankName",      limit: 45, default: "", null: false
    t.string "BankBranch",    limit: 45, default: "", null: false
  end

  create_table "employeebenefits", primary_key: "EmployeeID", force: :cascade do |t|
    t.string  "MedicalInsuranceType", limit: 10, default: "", null: false
    t.boolean "isPickAndDropAvailed",                         null: false
    t.integer "ConveyancePolicy",     limit: 4
    t.float   "AccrualPercentage",    limit: 24
  end

  create_table "employeeearnedleavedetails", primary_key: "detailID", force: :cascade do |t|
    t.string  "EmployeeID", limit: 6,  default: "", null: false
    t.integer "Month",      limit: 4,               null: false
    t.integer "Year",       limit: 4,               null: false
    t.float   "Casual",     limit: 53,              null: false
    t.float   "Annual",     limit: 53,              null: false
    t.float   "Additional", limit: 53
  end

  create_table "employeeearnedleaves", primary_key: "EmployeeID", force: :cascade do |t|
    t.float   "Casual",              limit: 53,               null: false
    t.float   "Annual",              limit: 53,               null: false
    t.float   "Additional",          limit: 53
    t.float   "TotalLeavesEncashed", limit: 53, default: 0.0
    t.integer "Accrued",             limit: 4
  end

  create_table "employeefamilies", primary_key: "EmployeeID", force: :cascade do |t|
    t.string  "MaritalStatus", limit: 10, default: "", null: false
    t.integer "NoOfChildren",  limit: 4,               null: false
  end

  create_table "employeefamilydetails", primary_key: "FamilyDetailID", force: :cascade do |t|
    t.string   "EmployeeID",   limit: 6,  default: "", null: false
    t.string   "Name",         limit: 45, default: "", null: false
    t.string   "Relationship", limit: 45, default: "", null: false
    t.datetime "DateOfBirth",                          null: false
  end

  create_table "employeeleaveencasheddetails", primary_key: "LeavesEncashedId", force: :cascade do |t|
    t.string "EmployeeId",           limit: 255
    t.date   "LeavesEncashedDate"
    t.float  "LeavesEncashed",       limit: 53
    t.float  "LeavesEncashedAmount", limit: 53
  end

  create_table "employeeleaves", primary_key: "LeaveID", force: :cascade do |t|
    t.string   "EmployeeID", limit: 6,  default: "", null: false
    t.datetime "Date",                               null: false
    t.string   "LeaveType",  limit: 10, default: "", null: false
    t.float    "Violations", limit: 53,              null: false
  end

  create_table "employeemedicalallowances", primary_key: "MedicalAllowanceID", force: :cascade do |t|
    t.string   "EmployeeID",       limit: 6,  default: "", null: false
    t.datetime "Date",                                     null: false
    t.float    "ReimbursedAmount", limit: 53
  end

  create_table "employeeperformances", primary_key: "PerformanceID", force: :cascade do |t|
    t.string   "EmployeeID",  limit: 6,   default: "", null: false
    t.datetime "Date",                                 null: false
    t.float    "BonusAmount", limit: 53,               null: false
    t.string   "Comment",     limit: 100, default: "", null: false
  end

  create_table "employeepersonaldetails", primary_key: "EmployeeID", force: :cascade do |t|
    t.string   "FirstName",         limit: 45,  default: "",    null: false
    t.string   "LastName",          limit: 45,  default: "",    null: false
    t.string   "Address",           limit: 45,  default: "",    null: false
    t.string   "HomePhoneNo",       limit: 11,  default: "",    null: false
    t.string   "CellPhoneNo",       limit: 15,  default: "",    null: false
    t.datetime "DateOfBirth",                                   null: false
    t.string   "Type",              limit: 45,  default: "",    null: false
    t.string   "HomeEmail",         limit: 45,  default: "",    null: false
    t.string   "OfficeEmail",       limit: 45,  default: "",    null: false
    t.datetime "DateOfJoining",                                 null: false
    t.string   "NTNNo",             limit: 15,  default: "",    null: false
    t.string   "NICNo",             limit: 15,  default: "",    null: false
    t.boolean  "isInactive"
    t.string   "Gender",            limit: 1
    t.boolean  "IsInternee",                                    null: false
    t.string   "Department",        limit: 255
    t.string   "Designation",       limit: 255
    t.datetime "AccrualStartDate"
    t.datetime "TerminationDate"
    t.boolean  "is_enrolled_in_pf",             default: false
    t.float    "pf_percentage",     limit: 53
    t.boolean  "isConsultant",                  default: false
  end

  create_table "employeesalaries", primary_key: "SalaryID", force: :cascade do |t|
    t.string   "EmployeeID",   limit: 6,  default: "", null: false
    t.float    "GrossSalary",  limit: 53,              null: false
    t.datetime "UpdationDate",                         null: false
  end

  create_table "eobidetails", primary_key: "ID", force: :cascade do |t|
    t.string   "EmployeeID",           limit: 6,  default: "", null: false
    t.datetime "Date",                                         null: false
    t.float    "CompanyContribution",  limit: 53,              null: false
    t.float    "EmployeeContribution", limit: 53,              null: false
  end

  create_table "leavedetails", primary_key: "Tenure", force: :cascade do |t|
    t.float "Casual",     limit: 53, null: false
    t.float "Annual",     limit: 53, null: false
    t.float "Additional", limit: 53, null: false
  end

  create_table "loandetails", primary_key: "LoanID", force: :cascade do |t|
    t.integer "EmployeeID",   limit: 4
    t.date    "DateApproved"
    t.float   "Amount",       limit: 53
    t.float   "Installment",  limit: 53
    t.float   "Balance",      limit: 53
    t.integer "iscomplete",   limit: 4
  end

  create_table "log", force: :cascade do |t|
    t.string   "username", limit: 15, default: "", null: false
    t.string   "action",   limit: 45, default: "", null: false
    t.datetime "datetime",                         null: false
  end

  create_table "medical_tax_exemptions", force: :cascade do |t|
    t.string "employee_id",                  limit: 255
    t.float  "exemption_for_month",          limit: 53
    t.float  "basic_salary_for_month",       limit: 53
    t.float  "projected_exemption_for_year", limit: 53
    t.date   "date"
  end

  create_table "medicalallowancedetails", primary_key: "MedicalAllowanceID", force: :cascade do |t|
    t.string  "MaritalStatus",   limit: 15, default: "", null: false
    t.integer "NoOfChildren",    limit: 4,               null: false
    t.float   "Allowance",       limit: 53,              null: false
    t.integer "FK_UpdationDate", limit: 4,               null: false
  end

  create_table "medicalallowanceupdates", primary_key: "MedicalAllowanceID", force: :cascade do |t|
    t.datetime "UpdationDate", null: false
  end

  create_table "pay_scales", force: :cascade do |t|
    t.string "title",              limit: 255
    t.float  "basic_salary_ratio", limit: 53
    t.float  "allowance_ratio",    limit: 53
    t.float  "min_select_ratio",   limit: 53
    t.float  "max_select_ratio",   limit: 53
  end

  create_table "payrolldetails", force: :cascade do |t|
    t.integer "idpayroll",                  limit: 4,                 null: false
    t.string  "employeeid",                 limit: 6,   default: "",  null: false
    t.string  "employeename",               limit: 90
    t.string  "bankaccountno",              limit: 45
    t.float   "additionalleaves",           limit: 53
    t.float   "violations",                 limit: 53
    t.float   "leavewop",                   limit: 53
    t.float   "conveyance",                 limit: 53
    t.float   "medical",                    limit: 53
    t.float   "bonus",                      limit: 53
    t.float   "CurrentAccrualbonusPercent", limit: 53,                null: false
    t.float   "accruedbonus",               limit: 53
    t.float   "tax",                        limit: 53
    t.float   "loan",                       limit: 53
    t.float   "eobi",                       limit: 53
    t.float   "adjustment",                 limit: 53
    t.float   "advance",                    limit: 53
    t.float   "deduction",                  limit: 53
    t.float   "salary",                     limit: 53
    t.float   "totaldeductions",            limit: 53
    t.float   "netpay",                     limit: 53
    t.integer "isPaySlipSent",              limit: 4
    t.float   "temptax",                    limit: 53
    t.float   "taxadjust",                  limit: 53
    t.string  "TaxRate",                    limit: 255
    t.string  "ActualTax",                  limit: 255
    t.string  "CoverUpTax",                 limit: 255
    t.string  "FloodSurcharge",             limit: 255
    t.string  "ProjectedAnnualIncome",      limit: 255
    t.string  "ProjectedAnnualTax",         limit: 255
    t.float   "LeavesEncashmentAmount",     limit: 53,  default: 0.0
    t.float   "NoOfLeavesEncashed",         limit: 53,  default: 0.0
    t.float   "med_tax_exmption",           limit: 53
    t.float   "casual_leaves_earned",       limit: 24,  default: 0.0
    t.float   "annual_leaves_earned",       limit: 24,  default: 0.0
    t.float   "casual_leave_balance",       limit: 24,  default: 0.0
    t.float   "annual_leave_balance",       limit: 24,  default: 0.0
    t.float   "additional_leave_balance",   limit: 24,  default: 0.0
    t.float   "reimbursement_balance",      limit: 24,  default: 0.0
  end

  create_table "payrolls", primary_key: "idpayroll", force: :cascade do |t|
    t.integer "month",              limit: 4
    t.integer "year",               limit: 4
    t.date    "startdate"
    t.date    "enddate"
    t.boolean "iscomplete"
    t.integer "FloodSurchargeDays", limit: 4, default: 0
  end

  create_table "paysliphistories", force: :cascade do |t|
    t.string   "EmployeeID",   limit: 6,  default: "", null: false
    t.integer  "Month",        limit: 4,               null: false
    t.integer  "Year",         limit: 4,               null: false
    t.float    "Deductions",   limit: 53,              null: false
    t.float    "NetTotal",     limit: 53,              null: false
    t.float    "IncomeTax",    limit: 53,              null: false
    t.datetime "UpdationDate",                         null: false
  end

  create_table "pm_employee_allocations", force: :cascade do |t|
    t.integer  "rm_project_id", limit: 4,                  null: false
    t.string   "EmployeeID",    limit: 6,  default: "",    null: false
    t.datetime "start_date",                               null: false
    t.datetime "end_date",                                 null: false
    t.integer  "percentage",    limit: 4,  default: 0,     null: false
    t.float    "hours",         limit: 24, default: 0.0,   null: false
    t.string   "month",         limit: 45
    t.integer  "year",          limit: 4
    t.boolean  "ishourly",                 default: true,  null: false
    t.boolean  "islocked",                 default: false
  end

  add_index "pm_employee_allocations", ["EmployeeID"], name: "EmployeeID", using: :btree
  add_index "pm_employee_allocations", ["rm_project_id"], name: "project_id", using: :btree

  create_table "prof_dollar_rates", force: :cascade do |t|
    t.float   "dollar_rate", limit: 24, default: 1.0
    t.integer "month",       limit: 4
    t.integer "year",        limit: 4
  end

  create_table "profitability_reports", id: false, force: :cascade do |t|
    t.integer "id",                    limit: 4,   null: false
    t.integer "div_id",                limit: 4
    t.integer "project_id",            limit: 4
    t.integer "employee_id",           limit: 4
    t.integer "designation_id",        limit: 4
    t.string  "month",                 limit: 255
    t.string  "year",                  limit: 255
    t.float   "invoice_amount",        limit: 24
    t.float   "percentage_allocation", limit: 24
    t.integer "no_of_days",            limit: 4
    t.float   "cogs",                  limit: 24
    t.float   "operational_exp",       limit: 24
    t.float   "profit",                limit: 24
  end

  add_index "profitability_reports", ["id"], name: "id", using: :btree

  create_table "project_invoice_numbers", force: :cascade do |t|
    t.integer "project_id",       limit: 4
    t.integer "month",            limit: 4
    t.integer "year",             limit: 4
    t.string  "invoice_no",       limit: 50
    t.integer "no_of_days",       limit: 2,   default: 30
    t.string  "net_payment_term", limit: 255, default: "Net 30 Days"
    t.boolean "IsCurrencyDollar",             default: true
    t.float   "dollar_rate",      limit: 24,  default: 1.0
    t.string  "invoice_date",     limit: 50
  end

  create_table "provident_fund_percentages", force: :cascade do |t|
    t.string "percentage", limit: 1, default: "4"
  end

  create_table "provident_funds", force: :cascade do |t|
    t.float  "employee_contribution",        limit: 53
    t.float  "employer_contribution",        limit: 53
    t.float  "percentage",                   limit: 53
    t.float  "total",                        limit: 53
    t.float  "return_on_investment",         limit: 53,  default: 0.0
    t.date   "date",                                                   null: false
    t.string "employeepersonaldetail_id",    limit: 255, default: "",  null: false
    t.float  "taxable_return_on_investment", limit: 53,  default: 0.0
  end

  create_table "rate_lists", force: :cascade do |t|
    t.string "EmployeeID",       limit: 6,   default: "",  null: false
    t.string "designation",      limit: 255, default: "",  null: false
    t.float  "team_based_rates", limit: 53,  default: 0.0, null: false
    t.float  "hour_based_rates", limit: 53,  default: 0.0, null: false
  end

  add_index "rate_lists", ["EmployeeID"], name: "EmployeeID_rlc1", using: :btree

  create_table "rates", id: false, force: :cascade do |t|
    t.integer  "id",               limit: 4,                 null: false
    t.integer  "designation_id",   limit: 4
    t.float    "team_based_rates", limit: 53
    t.float    "hour_based_rates", limit: 53
    t.boolean  "iscurrent",                   default: true
    t.datetime "revision_date"
  end

  add_index "rates", ["id"], name: "id", using: :btree

  create_table "resource_allocation_reports", force: :cascade do |t|
    t.string  "employee_id",         limit: 255
    t.string  "employee_name",       limit: 255
    t.float   "percent_alloc",       limit: 24
    t.float   "percent_billable",    limit: 24
    t.float   "percent_unbillable",  limit: 24
    t.float   "percent_shadow",      limit: 24
    t.float   "loss_at_pms_end",     limit: 24
    t.float   "loss_at_finance_end", limit: 24
    t.integer "MONTH",               limit: 4
    t.integer "YEAR",                limit: 4
  end

  create_table "rm_allocation_records", force: :cascade do |t|
    t.integer "project_id",       limit: 4,                   null: false
    t.string  "employee_id",      limit: 255, default: ""
    t.boolean "ishourly"
    t.float   "hours",            limit: 24
    t.string  "month",            limit: 255
    t.string  "year",             limit: 255
    t.float   "percent_billing",  limit: 24
    t.string  "project_name",     limit: 255
    t.string  "employee_name",    limit: 255
    t.string  "email",            limit: 100
    t.boolean "IsShadow",                     default: false
    t.date    "start_date"
    t.date    "end_date"
    t.integer "no_of_days",       limit: 4,   default: 0
    t.float   "percentage_alloc", limit: 24
    t.float   "LEAVES",           limit: 53,  default: 0.0
    t.string  "task_notes",       limit: 500
  end

  create_table "rm_project_allocations", force: :cascade do |t|
    t.integer  "rm_project_id", limit: 4,  default: 0,    null: false
    t.string   "EmployeeID",    limit: 6,  default: "",   null: false
    t.integer  "percentage",    limit: 4,  default: 0,    null: false
    t.integer  "hours",         limit: 4,  default: 0,    null: false
    t.datetime "start_date",                              null: false
    t.datetime "end_date",                                null: false
    t.string   "month",         limit: 50
    t.integer  "year",          limit: 4
    t.boolean  "ishourly",                 default: true
  end

  add_index "rm_project_allocations", ["EmployeeID"], name: "EmployeeID", using: :btree
  add_index "rm_project_allocations", ["rm_project_id"], name: "rm_project_id", using: :btree

  create_table "rm_projects", primary_key: "project_id", force: :cascade do |t|
    t.string "name",                    limit: 255, default: "", null: false
    t.string "status",                  limit: 100
    t.string "customer_name",           limit: 100
    t.string "customer_address",        limit: 100
    t.string "customer_personal_email", limit: 100
    t.string "customer_invoice_email",  limit: 100
    t.string "director_name",           limit: 100
  end

  create_table "schema_info", id: false, force: :cascade do |t|
    t.integer "version", limit: 4
  end

  create_table "taxcredits", id: false, force: :cascade do |t|
    t.string  "EmployeeId",   limit: 255, default: "", null: false
    t.string  "FiscalYear",   limit: 255, default: "", null: false
    t.float   "AnnualAmount", limit: 53
    t.string  "Detail",       limit: 255
    t.integer "id",           limit: 4,                null: false
  end

  create_table "taxes", primary_key: "TaxID", force: :cascade do |t|
    t.float   "IncomeUpperLimit", limit: 53,                null: false
    t.float   "IncomeLowerLimit", limit: 53,                null: false
    t.float   "TaxRate",          limit: 53,                null: false
    t.integer "tax_scheme_year",  limit: 4,  default: 2012
    t.integer "constant_tax",     limit: 4,  default: 0
  end

  create_table "taxexemptions", id: false, force: :cascade do |t|
    t.string  "EmployeeId",   limit: 255, default: "", null: false
    t.string  "FiscalYear",   limit: 255, default: "", null: false
    t.float   "AnnualAmount", limit: 53
    t.string  "Detail",       limit: 255
    t.integer "id",           limit: 4,                null: false
  end

  create_table "taxrebate", primary_key: "RebateTaxID", force: :cascade do |t|
    t.integer "SalaryUpperLimit", limit: 4
    t.float   "RebateRate",       limit: 24
  end

  create_table "temp_projects", primary_key: "project_id", force: :cascade do |t|
    t.string "name",                    limit: 255, default: "", null: false
    t.string "status",                  limit: 100
    t.string "customer_name",           limit: 100
    t.string "customer_address",        limit: 100
    t.string "customer_personal_email", limit: 100
    t.string "customer_invoice_email",  limit: 100
    t.string "director_name",           limit: 100
  end

  create_table "temptaxes", primary_key: "TaxID", force: :cascade do |t|
    t.string   "EmployeeID", limit: 6,  default: "", null: false
    t.float    "Amount",     limit: 53
    t.float    "TaxAmount",  limit: 53
    t.datetime "Date"
    t.string   "TaxScheme",  limit: 10
  end

  create_table "tests", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "total_invoice_initiation_details", id: false, force: :cascade do |t|
    t.integer  "id",         limit: 4
    t.integer  "project_id", limit: 4,  null: false
    t.integer  "month",      limit: 4
    t.integer  "year",       limit: 4
    t.boolean  "IsSent"
    t.string   "heading",    limit: 50
    t.datetime "createdon"
  end

  create_table "total_invoice_initiations", id: false, force: :cascade do |t|
    t.float   "amount",                               limit: 24
    t.string  "description",                          limit: 255
    t.integer "total_invoice_initiations_details_id", limit: 4
  end

  create_table "total_invoices", force: :cascade do |t|
    t.integer  "project_id",       limit: 4,                    null: false
    t.string   "employee_id",      limit: 255,  default: "",    null: false
    t.boolean  "ishourly"
    t.float    "hours",            limit: 24
    t.float    "rates",            limit: 24
    t.float    "amount",           limit: 24
    t.string   "month",            limit: 255
    t.string   "year",             limit: 255
    t.datetime "createdon"
    t.string   "description",      limit: 1000
    t.float    "percent_billing",  limit: 24
    t.float    "percentage_alloc", limit: 24
    t.boolean  "IsAdjustment",                  default: false
    t.boolean  "add_less",                      default: true
    t.boolean  "IsSent",                        default: true
    t.float    "unpaid_leaves",    limit: 53,   default: 0.0
    t.integer  "no_of_days",       limit: 4,    default: 0
    t.string   "task_notes",       limit: 500
    t.binary   "reminder",         limit: 500
    t.date     "start_date"
    t.date     "end_date"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "username",               limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "variables", force: :cascade do |t|
    t.string "VariableName", limit: 50
    t.string "Value",        limit: 255, default: "0"
  end

  add_foreign_key "authenticates", "employeepersonaldetails", column: "rm_user_id", primary_key: "EmployeeID", name: "authenticates_ibfk_1", on_update: :cascade, on_delete: :cascade
  add_foreign_key "rate_lists", "employeepersonaldetails", column: "EmployeeID", primary_key: "EmployeeID", name: "EmployeeID_rlc1"
  add_foreign_key "rm_project_allocations", "employeepersonaldetails", column: "EmployeeID", primary_key: "EmployeeID", name: "EmployeeID", on_update: :cascade, on_delete: :cascade
end
