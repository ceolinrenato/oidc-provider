class TokenEndpointSerializer < BaseSerializer
  def initialize(authorization_code)
    access_token = authorization_code.access_token
    response_body = {
      access_token: access_token.token,
      token_type: "Bearer",
      refresh_token: access_token.refresh_tokens.last.token,
      expires_in: OIDC_PROVIDER_CONFIG[:expiration_time],
      id_token: access_token.id_token
    }
    super(response_body)
  end
end
