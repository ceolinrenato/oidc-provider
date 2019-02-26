Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get  'auth/lookup',            to: 'auth#lookup'
  post 'auth/sign_in',           to: 'auth#sign_in'
end
