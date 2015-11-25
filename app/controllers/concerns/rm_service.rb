class RmService
	extend ActiveSupport::Concern

	RM_SERVICE = YAML.load_file("#{Rails.root.to_s}/config/rm_tool_service.yml")

	def initialize
		@url = RM_SERVICE['rm_tool']
		@root_url = @url['root_url']
	end

	def get_all_projects
		@projects_url = @url['projects_url'].gsub('%{root_url}', @root_url)
	end

	def get_all_designations
		@designations_url = @url['designations_url'].gsub('%{root_url}', @root_url)
	end

	def get_employee_history_of_allocations(p_id, s_date, e_date)
		initialize_url = YAML.load_file("#{Rails.root.to_s}/config/rm_tool_service.yml") #loading file every time this function is call

		@history_url = initialize_url['rm_tool']['history_of_allocations_url']
		
		@history_url.gsub!(/%{root_url}|%{project_id}|%{start_date}|%{end_date}/) do |attributes|
			case attributes
			when "%{root_url}"
				@root_url
			when "%{project_id}"
				p_id.to_s
			when "%{start_date}"
				s_date.to_s
			when "%{end_date}"
				e_date.to_s
			end
		end

		@history_url
	end

	def get_all_project_alloc(month, year)
		initialize_url = YAML.load_file("#{Rails.root.to_s}/config/rm_tool_service.yml")
		@all_project_url = initialize_url['rm_tool']['all_projects_allocation_url']

		@all_project_url.gsub!(/%{root_url}|%{month}|%{year}/) do |attributes|
			case attributes
			when "%{root_url}"
				@root_url
			when "%{month}"
				month.to_s
			when "%{year}"
				year.to_s
			end
		end

		@all_project_url
	end

	def get_project_alloc(pro_id, month, year)
		initialize_url = YAML.load_file("#{Rails.root.to_s}/config/rm_tool_service.yml")
		@all_project_url = initialize_url['rm_tool']['project_allocations_url']

		urls_changed_for_and_by(@all_project_url, pro_id, month, year)
	end

	def get_invoices_status(p_id, month, year)
		initialize_url = YAML.load_file("#{Rails.root.to_s}/config/rm_tool_service.yml") #loading file every time this function is call

		@status_url = initialize_url['rm_tool']['get_invoices_status']
		
		urls_changed_for_and_by(@status_url, p_id, month, year)
	end

	private 

	def urls_changed_for_and_by(url, p_id, month, year)
		url.gsub!(/%{root_url}|%{project_id}|%{month}|%{year}/) do |attributes|
			case attributes
			when "%{root_url}"
				@root_url
			when "%{project_id}"
				p_id.to_s
			when "%{month}"
				month.to_s
			when "%{year}"
				year.to_s
			end
		end

		url
	end
end
