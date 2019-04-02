require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def valid_access_token
    payload = {
      iss: OIDC_PROVIDER_CONFIG[:iss],
      sub: users(:example).id.to_s,
      iat: Time.now.to_i,
      exp: Time.now.to_i + OIDC_PROVIDER_CONFIG[:expiration_time]
    }
    tk = JWT.encode payload, TokenDecode::RSA_PRIVATE, 'RS256'
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    iv = cipher.random_iv
    cipher.key = TokenDecode::AES_KEY
    cipher.iv = iv
    "#{Base64.urlsafe_encode64(iv, padding: false)}.#{Base64.urlsafe_encode64(cipher.update(tk) + cipher.final, padding: false)}"
  end

  def tampered_access_token
    payload = {
      iss: OIDC_PROVIDER_CONFIG[:iss],
      sub: users(:example2).id.to_s,
      iat: Time.now.to_i,
      exp: Time.now.to_i + OIDC_PROVIDER_CONFIG[:expiration_time]
    }
    tk = JWT.encode payload, nil, 'none'
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    iv = cipher.random_iv
    cipher.key = TokenDecode::AES_KEY
    cipher.iv = iv
    "#{Base64.urlsafe_encode64(iv, padding: false)}.#{Base64.urlsafe_encode64(cipher.update(tk) + cipher.final, padding: false)}"
  end

  test "userinfo_endpoint_must_return_userinfo_if_valid_token" do
    get '/userinfo', headers: { 'Authorization' => "Bearer #{valid_access_token}"}
    assert_response :success
    userinfo = parsed_response(@response)
    assert_equal users(:example).id.to_s, userinfo["sub"]
  end

  test "userinfo_endpoint_must_return_unauthorized_if_no_token" do
    get '/userinfo'
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "userinfo_must_return_unauthorized_if_invalid_token" do
    get '/userinfo', headers: { 'Authorization' => "Bearer invalid_token" }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "userinfo_must_return_unauthorized_if_tampered_token" do
    get '/userinfo', headers: { 'Authorization' => "Bearer #{tampered_access_token}" }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "userinfo_must_not_accepted_modified_initialization_vector" do
    tk = valid_access_token.split('.')
    iv = tk.first + 'mod'
    modified_token = "#{iv}.#{tk.last}"
    get '/userinfo', headers: { 'Authorization' => "Bearer #{modified_token}" }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

  test "userinfo_must_not_accepted_modified_cipher" do
    tk = valid_access_token.split('.')
    cipher = tk.last + 'mod'
    modified_token = "#{tk.first}.#{cipher}"
    get '/userinfo', headers: { 'Authorization' => "Bearer #{modified_token}" }
    assert_response :unauthorized
    assert_not_nil @response.headers['WWW-Authenticate']
  end

end
