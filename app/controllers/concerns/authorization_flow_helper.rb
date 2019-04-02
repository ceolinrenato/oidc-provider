module AuthorizationFlowHelper
  extend ActiveSupport::Concern

  private

  AUTHORIZATION_FLOWS = {
    'code' => {
      method: :authorization_code_flow,
      default_mode: 'query'
    },
    'id_token token' => {
      method: :implicit_flow,
      default_mode: 'fragment'
    },
    'id_token' => {
      method: :implicit_flow,
      default_mode: 'fragment'
    },
    'token' => {
      method: :implicit_flow,
      default_mode: 'fragment'
    },
    'code id_token token' => {
      method: :hybrid_flow,
      default_mode: 'fragment'
    },
    'code id_token' => {
      method: :hybrid_flow,
      default_mode: 'fragment'
    },
    'code token' => {
      method: :hybrid_flow,
      default_mode: 'fragment'
    }
  }

  def authorization_code_flow
    generate_auth_code
    generate_access_token
    generate_auth_scopes
    generate_refresh_token
    response_data = {
      code: @authorization_code.code,
      state: params[:state]
    }
    redirect_with_response @redirect_uri.uri, response_data
  end

  def implicit_flow
    generate_access_token
    generate_auth_scopes
    response_data = Hash.new
    if @response_type.split.include? 'token'
      response_data[:access_token] = @access_token.token
      response_data[:token_type] = 'Bearer'
    end
    response_data[:id_token] = @access_token.id_token(response_data[:access_token], params[:nonce]) if @response_type.split.include? 'id_token'
    response_data[:expires_in] = OIDC_PROVIDER_CONFIG[:expiration_time]
    response_data[:state] = params[:state] if params[:state]
    redirect_with_response @redirect_uri.uri, response_data
  end

  def hybrid_flow
    generate_auth_code
    generate_access_token
    generate_auth_scopes
    generate_refresh_token
    response_data = Hash.new
    response_data[:code] = @authorization_code.code
    if @response_type.split.include? 'token'
      response_data[:access_token] = @access_token.token
      response_data[:token_type] = 'Bearer'
    end
    response_data[:id_token] = @access_token.id_token(response_data[:access_token], params[:nonce]) if @response_type.split.include? 'id_token'
    response_data[:expires_in] = OIDC_PROVIDER_CONFIG[:expiration_time]
    response_data[:state] = params[:state] if params[:state]
    redirect_with_response @redirect_uri.uri, response_data
  end

end
