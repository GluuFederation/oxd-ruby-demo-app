class ApplicationController < ActionController::Base

	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	layout "application"
	require 'resolv-replace'
	require 'oxd-ruby'
	protect_from_forgery with: :exception

	before_action :set_oxd_commands_instance

	# @return [Boolean] type for openID Provider type, True for dynamic and False for static openID provider
	# method to know static or dynamic openID Provider
	# This should be called after getting the URI of the OpenID Provider, Client Redirect URI, Post logout URI, oxd port values from user
	def check_openid_type(op_host)
		op_host = op_host+"/.well-known/openid-configuration"
		uri = URI.parse(op_host)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		ophost_data = response.body
		@oxdConfig.dynamic_registration = (!JSON.parse(ophost_data).key?("registration_endpoint"))? false : true
		@oxdConfig.scope = ["openid", "profile", "email"] if(@oxdConfig.dynamic_registration == false)
	end	

	protected
		def set_oxd_commands_instance
    		@oxd_command = Oxd::ClientOxdCommands.new
			@uma_command = Oxd::UMACommands.new
      		@oxdConfig = @oxd_command.oxdConfig
		end
end
