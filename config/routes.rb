Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # AccountManagement redirection
  get    '/',                                       to: 'application#redirect_to_account_management'

  # LoginService Routes
  get    'sign_in_service/email_lookup',            to: 'sign_in_service#email_lookup'
  get    'sign_in_service/consent_lookup',          to: 'sign_in_service#consent_lookup'
  get    'sign_in_service/request_validation',      to: 'sign_in_service#request_validation'
  post   'sign_in_service/credential_validation',   to: 'sign_in_service#credential_validation'

  # AuthorizationEndpoint Routes
  post   'oauth2/credential_authorization',         to: 'authorization_endpoint#credential_authorization'
  post   'oauth2/session_authorization',            to: 'authorization_endpoint#session_authorization'
  get    'oauth2/authorize',                        to: 'authorization_endpoint#request_validation'
  post   'oauth2/authorize',                        to: 'authorization_endpoint#request_validation'

  # SessionManagement Routes
  patch  'sessions/:session_token',                 to: 'session_management#sign_out'
  get    'sessions',                                to: 'session_management#index_by_device'
  delete 'sessions/:session_token',                 to: 'session_management#destroy'

  # TokenEndpoint Routes
  post   'oauth2/token',                           to: 'token_endpoint#grant_token'

  # UserInfo Routes
  get    'userinfo',                               to: 'users#show'
  post   'userinfo',                               to: 'users#show'

  # Discovery Routes
  get    '.well-known/openid-configuration',       to: 'discovery#show'
  get    'jwks.json',                              to: 'discovery#jwk'

  # Devices Routes
  get    '/users/:user_id/devices',                to: 'devices#index_by_user'

  # RelyingParties Routes
  get    '/users/:user_id/relying_parties',        to: 'relying_parties#index_by_user'

  # Users Routes
  patch  '/users/:user_id',                        to: 'users#update_profile'
  put    '/users/:user_id/password',               to: 'users#update_password'

end
