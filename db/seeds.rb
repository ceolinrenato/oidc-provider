# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Scopes

OIDC_PROVIDER_CONFIG[:scopes].each { |name| Scope.create name: name }
account_management = RelyingParty.create client_name: 'Account Management'
RedirectUri.create relying_party: account_management, uri: OIDC_PROVIDER_CONFIG[:account_management]
