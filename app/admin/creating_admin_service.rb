module CreatingAdminService
	def call
		admin = User.find_or_create_by!(username: Rails.application.secrets.admin_username) do |admin|
      admin.password = Rails.application.secrets.admin_password
      admin.password_confirmation = Rails.application.secrets.admin_password
      admin.email = Rails.application.secrets.admin_email
    end
	end

	module_function :call
end