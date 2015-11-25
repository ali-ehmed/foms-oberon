module EmployeesHelper
	Gender = [
		{:gender_id => "0", :gender_name => "Male"},
		{:gender_id => "1", :gender_name => "Female"}
	]
	MaritalStatus = ["Single", "Married"]
	Conveyance = [
		{:conveyance_id => "1", :conveyance_name => "standard"},
		{:conveyance_id => "2", :conveyance_name => "van_service"},
		{:conveyance_id => "3", :conveyance_name => "parking"},
		{:conveyance_id => "4", :conveyance_name => "pick_and_drop"},
		{:conveyance_id => "5", :conveyance_name => "no_conveyance"},
	]
	MedicalInsurance = ["takaful", "alianz"]
end