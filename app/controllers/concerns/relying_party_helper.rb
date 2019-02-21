module RelyingPartyHelper
  extend ActiveSupport::Concern

  def set_relying_party_by_client_id
    raise CustomExceptions::InvalidRequest.new "'client_id' required." unless params[:client_id]
    @relying_party = RelyingParty.find_by client_id: params[:client_id]
    raise CustomExceptions::InvalidClient.new unless @relying_party
  end

end
