class ProjectsController < ApplicationController
	before_action :authenticate_user!
  def index
  	@projects = RmProject.all

  	respond_to do |format|
  		format.html
  		format.json { render json: { data: @projects } }
		end
  end

  def sync_projects

  	@rm_url = RmService.new
  	@doc = Nokogiri::XML(open(@rm_url.get_all_projects))
  	@xml_data = @doc.css("Projects Project")

  	rm_projects = Array.new

  	@xml_data.each do |rm_project|

  		project_status = rm_project.css('ProjectStatus').text

  		case project_status
  		when "1"
        status = "Active"
      when "5"
          status = "OnDemand"
      else
        status = project_status
      end

      attributes = {
        :project_id => rm_project.css('ProjectId').text,
        :status => status,
        :name => rm_project.css('ProjectName').text,
        :director_name => rm_project.css('DirectorName').text,
        :customer_name => rm_project.css('CustomerName').text,
        :customer_address => rm_project.css('Address').text,
        :customer_personal_email => rm_project.css('PersonalEmail').text,
        :customer_invoice_email => rm_project.css('InvoiceEmail').text,
      }

      rm_projects << attributes
  	end

  	logger.debug "Destroying Old Projects"
  	
		RmProject.destroy_all if RmProject.count > 0

  	logger.debug "Creating New Projects"
  	@projects = RmProject.create rm_projects

  	respond_to do |format|
  		format.json { render json: { status: :synced_all, data: @projects  }, status: :created }
		end

  end
end
