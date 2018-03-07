Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'
  resources :open_id do
    collection do
      get 'setup_client'
      get 'get_client_token'
      get 'introspect_access_token'
      get 'update_registration'
      get 'delete_registration'
      get 'register_site'
      get 'login'
      get 'logout'
      get 'clear_data'
    end
  end
  
  resources :uma do
    collection do
      get 'protect_resources'
      get 'protect_resources_with_scope_expression'
      get 'get_client_token'
      get 'introspect_rpt'
      get 'get_rpt'
      get 'check_access'
      get 'get_claims_gathering_url'
      get 'claims'
    end
  end
end
