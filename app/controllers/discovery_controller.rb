class DiscoveryController < ApplicationController
  def show
    # service_documentation: "#{OIDC_PROVIDER_CONFIG[:iss]}/doc"
    # op_policy_uri: "#{OIDC_PROVIDER_CONFIG[:iss]}/privacy_policy"
    # op_tos_uri: "#{OIDC_PROVIDER_CONFIG[:iss]}/terms_of_service"
    metadata = {
      issuer: OIDC_PROVIDER_CONFIG[:iss],
      authorization_endpoint: "#{OIDC_PROVIDER_CONFIG[:iss]}/oauth2/authorize",
      token_endpoint: "#{OIDC_PROVIDER_CONFIG[:iss]}/oauth2/token",
      userinfo_endpoint: "#{OIDC_PROVIDER_CONFIG[:iss]}/userinfo",
      jwks_uri: "#{OIDC_PROVIDER_CONFIG[:iss]}/jwks.json",
      scopes_supported: Scope.scope_list,
      response_types_supported: ResponseTypeHelper::SUPPORTED_RESPONSE_TYPES,
      response_modes_supported: ['query', 'fragment'],
      grant_types_supported: GrantTypeHelper::SUPPORTED_GRANT_TYPES.dup << 'implicit',
      subject_types_supported: ['public'],
      id_token_signing_alg_values_supported: ['RS256'],
      token_endpoint_auth_methods_supported: ['client_secret_post'],
      claim_types_supported: ['normal'],
      claims_supported: ['sub', 'name', 'given_name', 'family_name', 'email', 'email_verified', 'updated_at'],
      claims_parameter_supported: false,
      request_parameter_supported: false,
      request_uri_parameter_supported: false
    }
    render json: metadata
  end

  def jwk
    public_key = TokenDecode::RSA_PRIVATE.public_key
    metadata = {
      keys: [
        {
          kty: 'RSA',
          e: Base64.urlsafe_encode64(public_key.params['e'].to_s(2), padding: false),
          use: 'sig',
          kid: 'Key used to validate id_token signature',
          alg: 'RS256',
          n: Base64.urlsafe_encode64(public_key.params['n'].to_s(2), padding: false)
        }
      ]
    }
    render json: metadata
  end
end
