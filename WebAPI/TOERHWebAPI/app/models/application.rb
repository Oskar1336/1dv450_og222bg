class Application < ActiveRecord::Base
	has_one :api_key
	
	# Validation
	validates :contact_mail, :application_name, :presence => true
	validates :contact_mail, email_format: { message:"Not a valid email" }, uniqueness: { case_sensitive: false }
end
