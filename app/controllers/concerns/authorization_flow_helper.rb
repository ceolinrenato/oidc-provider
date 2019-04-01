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
    set_response_mode
    generate_auth_code
    generate_access_token
    generate_auth_scopes
    generate_refresh_token
    response = {
      code: @authorization_code.code,
      state: params[:state]
    }
    redirect_with_response @redirect_uri.uri, response
  end

  def implicit_flow
    raise CustomExceptions::InvalidRequest.new 34 unless params[:nonce]
    set_response_mode
    generate_access_token
    generate_auth_scopes
    response = Hash.new
    if @response_type.split.include? 'token'
      response[:access_token] = @access_token.token
      response[:token_type] = 'Bearer'
    end
    response[:id_token] = @access_token.id_token(response[:access_token], params[:nonce]) if @response_type.split.include? 'id_token'
    response[:expires_in] = OIDC_PROVIDER_CONFIG[:expiration_time]
    response[:state] = params[:state] if params[:state]
    redirect_with_response @redirect_uri.uri, response
  end

  def hybrid_flow
    set_response_mode
    generate_auth_code
    generate_access_token
    generate_auth_scopes
    generate_refresh_token
    response = Hash.new
    response[:code] = @authorization_code.code
    if @response_type.split.include? 'token'
      response[:access_token] = @access_token.token
      response[:token_type] = 'Bearer'
    end
    response[:id_token] = @access_token.id_token(response[:access_token], params[:nonce]) if @response_type.split.include? 'id_token'
    response[:expires_in] = OIDC_PROVIDER_CONFIG[:expiration_time]
    response[:state] = params[:state] if params[:state]
    redirect_with_response @redirect_uri.uri, response
  end

  def set_response_mode
    @response_mode = params[:response_mode] ? params[:response_mode] : AUTHORIZATION_FLOWS[@response_type][:default_mode]
    raise CustomExceptions::InvalidRequest.new 35 unless ['query', 'fragment'].include?(@response_mode)
  end

  def redirect_with_response(location, response)
    @response_mode == 'query' ? redirect_with_params(location, response) : redirect_with_fragment(location, response)
  end

end
