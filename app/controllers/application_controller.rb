class ApplicationController < ActionController::API
  include ActionController::Cookies

  private

  def bearer_authorization
    token = get_bearer_token
    puts token
    unless token
      response.headers['WWW-Authenticate'] = 'Bearer'
      head :unauthorized and return
    end
    @access_token = TokenDecode::AccessToken.new(token).decode
  end

  def get_bearer_token
    pattern = /^Bearer /
    header  = request.headers["Authorization"]
    puts header
    header.gsub(pattern, '') if header && header.match(pattern)
  end

end
