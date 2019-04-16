# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do

  allow do
    origins Rails.application.config.allowed_cors_origins

    resource '/sign_in_service/email_lookup',
      headers: :any,
      methods: [:get]

    resource '/sign_in_service/consent_lookup',
      headers: :any,
      methods: [:get]

    resource '/sign_in_service/request_validation',
      headers: :any,
      methods: [:get]

    resource '/sign_in_service/credential_validation',
      headers: :any,
      methods: [:post]

    resource '/sessions',
      headers: :any,
      methods: [:get],
      credentials: true

    resource '/sessions/*',
      headers: :any,
      methods: [:delete, :patch, :options],
      credentials: true

  end

  allow do
    origins '*'

    resource '/userinfo',
      headers: :any,
      methods: [:get, :post]

    resource '/.well-known/openid-configuration',
      headers: :any,
      methods: [:get]

    resource '/jwks.json',
      headers: :any,
      methods: [:get]

    resource '/users/*',
      headers: :any,
      methods: [:get, :patch, :put, :options]

  end

end
