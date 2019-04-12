class ApplicationController < ActionController::API
  include ActionController::Cookies

  def redirect_to_account_management
    redirect_to OIDC_PROVIDER_CONFIG[:account_management], status: :found
  end

  private

  def bearer_authorization
    token = get_bearer_token
    unless token
      response.headers['WWW-Authenticate'] = www_auth_header
      head :unauthorized and return
    end
    @access_token = TokenDecode::AccessToken.new(token).decode
    @authenticated_user = User.find_by id: @access_token["sub"]
  rescue CustomExceptions::InvalidAccessToken => exception
    response.headers['WWW-Authenticate'] = www_auth_header exception
    head :unauthorized and return
  end

  def get_bearer_token
    return params[:access_token] if request.method == 'POST' && !request.headers['Authorization']
    pattern = /^Bearer /
    header  = request.headers["Authorization"]
    header.gsub(pattern, '') if header && header.match(pattern)
  end

  def www_auth_header(exception = nil)
    parts = ["Bearer realm=\"#{request.path}\""]
    if exception
      parts << "error=\"#{exception.error}\""
      parts << "error_description=\"#{exception.error_description}\""
    end
    parts.join(', ')
  end

end
