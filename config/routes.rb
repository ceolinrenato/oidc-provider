Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'users/lookup',            to: 'users#lookup'
  get 'device_recognition',      to: 'users#device_recognition'
end
