# README

OIDC Provider (Basic, Implicit, Hybrid and Config OP)

* Ruby version

2.6.2

* Configuration

CORS origins specified for each config/environments file: development.rb, test.rb, production.rb

config/oidc_provider.yml for expiration time and issuer
config/sign_in_service.yml for SignInService uri
config/database.yml for database settings
config/errors.yml for error messages

rails credentials:edit for RSA and AES keys


* Database creation

rails db:setup for database initialization and seeding
rails db:reset to wipe database and start over

* How to run the test suite

rails tests

* Deployment instructions

Deployment pipeline yet to do
