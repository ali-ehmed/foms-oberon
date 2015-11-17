class ProjectsController < ApplicationController
  def index
  	@projects = RmProject.all

  	respond_to do |format|
  		format.html
  		format.json { render json: { data: @projects } }
		end
  end

  def sync_projects
    # RmProject.destroy_all if RmProject.count > 0
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
          status = "On Demand"
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

      

      existing_project = RmProject.find_by_name(attributes[:name])
      if existing_project.present?
        logger.debug "Updating Old Project"
        existing_project.update_attributes(attributes)
      else
        logger.debug "Creating New Project"
        RmProject.create attributes
      end
  	end

    @projects = RmProject.all

  	respond_to do |format|
  		format.json { render json: { status: :synced_all, data: @projects  }, status: :created }
		end

  end
end
