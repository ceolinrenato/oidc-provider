Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # LoginService Routes
  get    'login_service/email_lookup',            to: 'login_service#email_lookup'
  get    'login_service/request_validation',      to: 'login_service#request_validation'
  post   'login_service/credential_validation',   to: 'login_service#credential_validation'

  # AuthorizationEndpoint Routes
  post   'oauth2/credential_authorization',       to: 'authorization_endpoint#credential_authorization'
  post   'oauth2/session_authorization',          to: 'authorization_endpoint#session_authorization'
  get    'oauth2/authorize',                      to: 'authorization_endpoint#request_validation'

  # SessionManagement Routes
  patch  'sessions/:session_token',               to: 'session_management#sign_out'
  get    'sessions',                              to: 'session_management#index_by_device'
  delete 'sessions/:session_token',               to: 'session_management#destroy'
end
