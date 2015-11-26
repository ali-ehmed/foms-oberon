class RatesController < ApplicationController
  def index
    # @rates = Rate.joins(:designation).where("iscurrent = ?", true).order("designation.designation_name asc").paginate(:page => params[:page], :per_page => 10)
    @rates = Rate.joins(:designation).where("iscurrent = ?", true).order("designations.designation asc").paginate(:page => params[:page], :per_page => 10)
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

    if @rate.save
      respond_to do |format|

        @designation = Designation.find_by_designation_id @rate.designation_id
        @designation.rates.update_all(:iscurrent => false)
 
        Rate.find(@rate.id).update_attribute(:iscurrent, true)

        @rates = Rate.where("iscurrent = ?", true).order("designation_id asc").paginate(:page => params[:page], :per_page => 10)
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
    @active_rate = @designation_rates.where("iscurrent = ?", true).first

    @designation_rates.update_all(:iscurrent => false)

    

    respond_to do |format|
      if params[:rate][:iscurrent]
        @rate.update_attribute(:iscurrent, true)
        format.json { respond_with_bip(@rate) }
      else

        if @rate.iscurrent == true
          Rate.find(@rate.id).update_attribute(:iscurrent, true) 
        else
          Rate.find(@active_rate.id).update_attribute(:iscurrent, true) unless @active_rate.blank?
        end

        if @rate.update_attributes(rates_params)
          format.json { respond_with_bip(@rate) }
        else
          format.json { respond_with_bip(@rate) }
        end
      end
    end
  end

  def sync_designations
  	@rm_url = RmService.new
  	@doc = Nokogiri::XML(open(@rm_url.get_all_designations))
  	@xml_data = @doc.css("Designations Positions")

    @rates = Rate.where("iscurrent = ?", true).order("designation_id asc").paginate(:page => params[:page], :per_page => 10)

  	rm_designations = Array.new

  	@xml_data.css("Positon").each do |rm_designation|
  		allocation = {
          
        :designation_id => rm_designation.css("Id").text,
        :designation => rm_designation.css("Name").text,

      }

      rm_designations << allocation
      
  	end

  	logger.debug "Removing Designations"
  	
    if Designation.count > 0 or Rate.count > 0
      Designation.destroy_all and Rate.destroy_all
    end

  	logger.debug "Fetching Designations"
  	Designation.create rm_designations

    logger.debug "Creating Rates"
    Designation.all.order("designation_id asc").each do |designation|
      rates_params = {
        :revision_date => Time.now,
        :iscurrent => 1,
        :team_based_rates => "0",
        :hour_based_rates => "0"
      }

      logger.debug "Creating Rates"
      @rate = designation.rates.build(rates_params)
      @rate.save
    end

  	respond_to do |format|
      format.js { render :file => "rates/index.js.erb" }
  		format.json { render json: { status: :synced_all  }, status: :created }
		end
  end

  private

  def rates_params
    params.require(:rate).permit(:designation_id, :team_based_rates, :hour_based_rates)
  end
end
