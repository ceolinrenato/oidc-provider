class TokenEndpointController < ApplicationController

  include GrantTypeHelper
  include RelyingPartyHelper
  include AuthorizationCodeHelper

  def code_grant
    ActiveRecord::Base.transaction do
      authenticate_relying_party
      set_grant_type
      set_authorization_code
      @authorization_code.update! used: true
    end
    render json: TokenEndpointSerializer.new(@authorization_code)
  rescue CustomExceptions::InvalidRequest,
    CustomExceptions::InvalidClient,
    CustomExceptions::UnauthorizedClient,
    CustomExceptions::UnsupportedGrantType,
    CustomExceptions::InvalidGrant => exception
    render json: ErrorSerializer.new(exception), status: :bad_request
  end

end
