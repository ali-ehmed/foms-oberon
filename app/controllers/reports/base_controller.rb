module Reports
	class BaseController < ApplicationController
		before_action :authenticate_user!

		def listing
			respond_to do |format|
				format.html { render :template => "/reports/listing" }
			end
		end
	end
end