class RatesController < ApplicationController
  def index
  	@revision_dates = Rate.group("revision_date")
		# @rates = Rate.where(:revision_date => params[:revision_date]) if params[:revision_date]

    @rates = Rate.group("designation_id")

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

  def create
    rates_params = {
      :designation_id => params[:designation],
      :revision_date => Time.now,
      :team_based_rates => params[:team_based_rate],
      :hour_based_rates => params[:hour_based_rate]
    }

    @rate = Rate.new(rates_params)
    @rate.iscurrent = 1
    @rate.revision_date = Time.now

    # Revision Date Present If
    if @rate.save
      respond_to do |format|

        @designation = Designation.find_by_designation_id @rate.designation_id
        @designation.rates.update_all(:iscurrent => false)

        @rate = Rate.find(@rate.id)
        @rate.update_attribute(:iscurrent, true)

        # @rates = Rate.where(:revision_date => params[:revision_date]) if params[:revision_date]
        @rates = Rate.group("designation_id")
        format.js { render :file => "rates/index.js.erb" }
      end
    else
      render json: 
        { status: :error, 
          errors: "#{@rate.errors.full_messages.map { |msg| content_tag(:li, msg) }.join}" 
        }, 
        status: :created 
    end
  end

  def update
    @rate = Rate.find params[:id]
    @designation = Designation.find_by_designation_id @rate.designation_id
    @designation_rates = @designation.rates
    @designation_rates.update_all(:iscurrent => false)

    respond_to do |format|
      if @rate.update_attributes(rates_params)
        @desig_rates = Rate.where("designation_id = ?", @rate.designation_id).order("revision_date")
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

    # If Revision Date Present
    # @rates = Rate.where(:revision_date => params[:revision_date]) if params[:revision_date]
    @rates = Rate.group("designation_id")

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

    Designation.all.each do |rate|
      rates_params = {
        :designation_id => rate.designation_id,
        :revision_date => Time.now,
        :iscurrent => 1,
        :team_based_rates => "0",
        :hour_based_rates => "0"
      }

      logger.debug "Creating Rates"
      Rate.create rates_params
    end

  	respond_to do |format|
      format.js { render :file => "rates/index.js.erb" }
  		format.json { render json: { status: :synced_all  }, status: :created }
		end
  end

  private

  def rates_params
    params.require(:rate).permit(:designation_id, :team_based_rates, :hour_based_rates, :iscurrent)
  end
end
