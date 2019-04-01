module AuthorizationFlowHelper
  extend ActiveSupport::Concern

  private

  AUTHORIZATION_FLOWS = {
    'code' => :authorization_code_flow,
    'id_token token' => :implicit_flow,
    'id_token' => :implicit_flow,
    'token' => :implicit_flow,
    'code id_token token' => :hybrid_flow,
    'code id_token' => :hybrid_flow,
    'code token' => :hybrid_flow
  }

  def authorization_code_flow
    generate_auth_code
    generate_access_token
    generate_auth_scopes
    generate_refresh_token
    redirect_with_params @redirect_uri.uri,
      {
        code: @authorization_code.code,
        state: params[:state]
      }
  end

  def implicit_flow
    raise CustomExceptions::InvalidRequest.new 34 unless params[:nonce]
    generate_access_token
    generate_auth_scopes
    fragment = Hash.new
    if @response_type.split.include? 'token'
      fragment[:access_token] = @access_token.token
      fragment[:token_type] = 'Bearer'
    end
    fragment[:id_token] = @access_token.id_token(fragment[:access_token], params[:nonce]) if @response_type.split.include? 'id_token'
    fragment[:expires_in] = OIDC_PROVIDER_CONFIG[:expiration_time]
    fragment[:state] = params[:state] if params[:state]
    redirect_with_fragment @redirect_uri.uri, fragment
  end

  def hybrid_flow
    generate_auth_code
    generate_access_token
    generate_auth_scopes
    generate_refresh_token
    fragment = Hash.new
    fragment[:code] = @authorization_code.code
    if @response_type.split.include? 'token'
      fragment[:access_token] = @access_token.token
      fragment[:token_type] = 'Bearer'
    end
    fragment[:id_token] = @access_token.id_token(fragment[:access_token], params[:nonce]) if @response_type.split.include? 'id_token'
    fragment[:expires_in] = OIDC_PROVIDER_CONFIG[:expiration_time]
    fragment[:state] = params[:state] if params[:state]
    redirect_with_fragment @redirect_uri.uri, fragment
  end

end
