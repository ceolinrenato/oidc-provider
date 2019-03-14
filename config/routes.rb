Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # Authorization
  get    'auth/lookup',                    to: 'auth#lookup'
  get    'auth/request_check',             to: 'auth#request_check'
  post   'auth/sign_in',                   to: 'auth#sign_in'
  post   'sessions/sign_in',               to: 'auth#sign_in_with_device'
  # Sessions
  get    'sessions',                       to: 'sessions#index_by_device'
  delete 'sessions/:session_token',        to: 'sessions#destroy'
end
