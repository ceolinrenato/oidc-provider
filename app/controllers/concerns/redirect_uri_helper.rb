module RedirectUriHelper
  extend ActiveSupport::Concern

  private

  def set_redirect_uri_by_param
    raise CustomExceptions::InvalidRequest, 3 unless params[:redirect_uri]
    @redirect_uri = RedirectUri.find_by 'relying_party_id = :relying_party_id AND uri = :uri', relying_party_id: @relying_party.id, uri: params[:redirect_uri]
    raise CustomExceptions::InvalidRedirectURI unless @redirect_uri
  end
end
