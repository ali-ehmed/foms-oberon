class RatesController < ApplicationController
  def index
  	@revision_dates = Rate.group("revision_date")
		@rates = Rate.where(:revision_date => params[:revision_date]) if params[:revision_date]

		respond_to do |format|
			format.html
			format.js
		end
  end

  def designation_rate_history
  	@designation = Designation.find_by_designation_id(params[:designation_id])
  	@designation_name = @designation.designation
  	@desig_rates = Rate.where("designation_id = ?", @designation.designation_id).order("revision_date")
  	respond_to do |format|
			format.js
		end
  end

  def update
    @rate = Rate.find_by_designation_id params[:designation_id]
    logger.debug "---------#{@rate.designation_id}------------"
    respond_to do |format|
      if @rate.update_attributes(rates_params)
        format.json { respond_with_bip(@rate) }
      else
        format.json { respond_with_bip(@rate) }
      end
    end
  end

  def sync_designations
  	@rm_url = RmService.new
  	@doc = Nokogiri::XML(open(@rm_url.get_all_designations))
  	@xml_data = @doc.css("Designations Positions")


  	rm_designations = Array.new

  	@xml_data.css("Positon").each do |rm_designation|
  		allocation = {
          
        :designation_id => rm_designation.css("Id").text,
        :designation => rm_designation.css("Name").text,

      }

      rm_designations << allocation
      
  	end

  	logger.debug "Removing Designations"
  	
  	Designation.destroy_all if Designation.count > 0

  	logger.debug "Fetching Designations"
  	Designation.create rm_designations

  	respond_to do |format|
  		format.json { render json: { status: :synced_all  }, status: :created }
		end
  end

  private

  def rates_params
    params.require(:rate).permit(:team_based_rates, :hour_based_rates)
  end
end
