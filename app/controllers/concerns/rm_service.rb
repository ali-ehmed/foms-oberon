class RmService
	extend ActiveSupport::Concern

	RM_SERVICE = YAML.load_file("#{Rails.root.to_s}/config/rm_tool_service.yml")

	def initialize
		@url = RM_SERVICE['rm_tool']
	end

	def get_all_projects
		@projects_url = @url['projects_url']
	end
end
