class UmaController < ApplicationController
	skip_before_action :verify_authenticity_token  
	require 'json'
    rescue_from StandardError, :with => :error_render_method

    def index       
    end

    def get_client_token
        @oxd_command.get_client_token
        redirect_to uma_index_path
    end

    def protect_resources
        condition1_for_path1 = {:httpMethods => ["GET"], :scopes => ["https://scim-test.gluu.org/identity/seam/resource/restv1/scim/vas1"]}
        @uma_command.uma_add_resource("/scim", condition1_for_path1) # Add Resource
        response = @uma_command.uma_rs_protect # Register above resources with UMA RS
        render :template => "uma/index", :locals => { :protect_resources_response => response } 
    end

    def protect_resources_with_scope_expression
        condition1 = {:httpMethods => ["GET"], :scope_expression => {:rule => { :and => [{:or => [{:var => 0},{:var => 1}]}, {:var => 2}]}, :data => ["https://scim-test.gluu.org/identity/seam/resource/restv1/scim/vas1"]}}
         @uma_command.uma_add_resource("/scim", condition1)
         
        response = @uma_command.uma_rs_protect # Register above resources with UMA RS
        render :template => "uma/index", :locals => { :protect_resources_with_scope_expression_response => response } 
    end

    def get_rpt
        begin
            state = nil
            if(session['claims_url'].present?)
                uri = URI.parse(session['claims_url'])
                params = CGI.parse(uri.query)
                state = params['state'].first
                @oxdConfig.ticket = params['ticket'].first
                session.delete('claims_url')
            end
            pct = nil
            pct = session['pct'] if session['pct'].present?
            response = @uma_command.uma_rp_get_rpt(state: state, pct: pct)
            session['pct'] = response['pct']
            render :template => "uma/index", :locals => { :get_rpt_response => response }            
        rescue Oxd::NeedInfoError => e
            get_claims_gathering_url
        rescue StandardError => e
            puts e.inspect
            abort
        end 
    end

    def introspect_rpt
        response = @uma_command.introspect_rpt
        render :template => "uma/index", :locals => { :introspect_rpt_response => response } 
    end

    def check_access
        response = @uma_command.uma_rs_check_access('/scim', 'GET')  # Pass the resource path and http method to check access
        render :template => "uma/index", :locals => { :check_access_response => response } 
    end

    def get_claims_gathering_url
        claims_url = @uma_command.uma_rp_get_claims_gathering_url("https://client.example.com/uma/claims")
        session["claims_url"] = claims_url       
        render :template => "uma/index", :locals => { :get_claims_gathering_url_response => claims_url }
    end

    def claims 
    end

    private
        def error_render_method(error)
            flash[:error] = error.message
            redirect_to uma_index_path
        end
end