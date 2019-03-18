Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # Authorization
  get    'auth/lookup',                    to: 'auth#lookup'
  get    'auth/request_check',             to: 'auth#request_check'
  get    'auth/credentials_check',         to: 'auth#credentials_check'
  post   'auth/sign_in',                   to: 'auth#sign_in'
  post   'auth/sign_in_with_session',      to: 'auth#sign_in_with_device'
  get    '/oauth2/authorize',              to: 'auth#request_check'
  # Sessions
  patch  'sessions/:session_token',        to: 'sessions#sign_out'
  get    'sessions',                       to: 'sessions#index_by_device'
  delete 'sessions/:session_token',        to: 'sessions#destroy'
end
