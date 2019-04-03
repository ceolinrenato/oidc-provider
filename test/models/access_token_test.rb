require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase

  def dummy_access_token
    {
      authorization_code: authorization_codes(:example),
      relying_party: relying_parties(:example),
      session: sessions(:example),
    }
  end

  test "should_create_valid_access_token" do
    access_token = AccessToken.new dummy_access_token
    assert access_token.save
  end

  test "token_method_must_generate_valid_encrypted_jws_token" do
    token = access_tokens(:example).token
    decoded_token = TokenDecode::AccessToken.new(token).decode
    payload = decoded_token.first
    headers = decoded_token.last
    assert_equal payload["sub"], access_tokens(:example).session.user.id.to_s
    assert_equal payload["aud"], access_tokens(:example).relying_party.client_id
    assert_equal payload["sid"], access_tokens(:example).session.token
    assert_equal payload["scopes"], access_tokens(:example).scopes.map { |scope| scope.name }
    assert_equal headers["alg"], 'RS256'
  end

  test "id_token_method_must_generate_valid_jws_token" do
    encrypted_access_token = access_tokens(:example).token
    token = access_tokens(:example).id_token(encrypted_access_token, 'test_nonce')
    decoded_token = TokenDecode::IDToken.new(token).decode
    payload = decoded_token.first
    headers = decoded_token.last
    assert_equal payload["sub"], access_tokens(:example).session.user.id.to_s
    assert_equal payload["aud"], access_tokens(:example).relying_party.client_id
    assert_equal payload["sid"], access_tokens(:example).session.token
    assert_equal payload["auth_time"], access_tokens(:example).session.auth_time.to_i
    assert_equal payload["at_hash"], Base64.urlsafe_encode64(Digest::SHA256.hexdigest(encrypted_access_token)[0,32], padding: false)
    if access_tokens(:example).authorization_code
      assert_equal payload["nonce"], access_tokens(:example).authorization_code.nonce if access_tokens(:example).authorization_code.nonce
      assert_equal payload["c_hash"], Base64.urlsafe_encode64(Digest::SHA256.hexdigest(access_tokens(:example).authorization_code.code)[0,32], padding: false)
    else
      assert_nil payload["c_hash"]
      assert_equal payload["nonce"], 'test_nonce'
    end
    assert_equal headers["alg"], 'RS256'
  end

end
