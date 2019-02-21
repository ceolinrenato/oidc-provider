module RedirectUriHelper
  extend ActiveSupport::Concern

  def set_redirect_uri_by_param
    raise CustomExceptions::InvalidRequest.new "'redirect_uri' required." unless params[:redirect_uri]
    raise CustomExceptions::InvalidRequest.new "redirect_uri not authorized by Relying Party" unless @relying_party.authorized_redirect_uri? params[:redirect_uri]
    @redirect_uri = RedirectUri.find_by 'relying_party_id = :relying_party_id AND uri = :uri', { relying_party_id: @relying_party.id, uri: params[:redirect_uri] }
  end

end
