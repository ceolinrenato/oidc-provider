require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def parsed_response(response)
    JSON.parse(response.body)
  end

  def set_device_token_cookie(token)
    "device_token=#{token}"
  end

  def build_redirection_uri(location, params)
    uri = URI(location)
    uri_params = Rack::Utils.parse_nested_query uri.query
    uri.query = uri_params.deep_merge(params).to_query
    uri.to_s
  end

  def build_redirection_uri_fragment(location, fragment)
    uri = URI(location)
    uri.fragment = fragment.to_query
    uri.to_s
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

  def valid_access_token(scopes = [])
    payload = {
      iss: OIDC_PROVIDER_CONFIG[:iss],
      sub: users(:example).id.to_s,
      iat: Time.now.to_i,
      exp: Time.now.to_i + OIDC_PROVIDER_CONFIG[:expiration_time],
      scopes: scopes
    }
    tk = JWT.encode payload, TokenDecode::RSA_PRIVATE, 'RS256'
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    iv = cipher.random_iv
    cipher.key = TokenDecode::AES_KEY
    cipher.iv = iv
    "#{Base64.urlsafe_encode64(iv, padding: false)}.#{Base64.urlsafe_encode64(cipher.update(tk) + cipher.final, padding: false)}"
  end

end
