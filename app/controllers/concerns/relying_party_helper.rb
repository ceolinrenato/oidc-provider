module RelyingPartyHelper
  extend ActiveSupport::Concern

  private

  def set_relying_party_by_client_id
    raise CustomExceptions::InvalidRequest.new 5 unless params[:client_id]
    @relying_party = RelyingParty.find_by client_id: params[:client_id]
    raise CustomExceptions::InvalidClient.new unless @relying_party
  end

  def authenticate_relying_party
    raise CustomExceptions::InvalidRequest.new 24 unless (params[:client_id] && params[:client_secret])
    @relying_party = RelyingParty.find_by 'client_id = :client_id AND client_secret = :client_secret',
                                          client_id: params[:client_id], client_secret: params[:client_secret]
    raise CustomExceptions::InvalidClient.new unless @relying_party
  end

  def third_party_authorization
    relying_party = RelyingParty.find_by client_id: @access_token["aud"]
    raise CustomExceptions::InsufficientPermissions.new 39 if relying_party.third_party
  end
end
