class SignInSerializer < BaseSerializer
  def initialize(authorization_code, device)
    response_body = {
      authorization_code: authorization_code.code,
      device_token: device.token
    }
    super(response_body)
  end
end
