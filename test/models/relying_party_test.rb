require 'test_helper'

class RelyingPartyTest < ActiveSupport::TestCase
  def dummy_relying_party
    {
      client_name: 'Example'
    }
  end

  test "should_create_valid_relying_party" do
    relying_party = RelyingParty.new dummy_relying_party
    assert relying_party.save
  end

  test "tos_uri_should_be_https" do
    relying_party = RelyingParty.new dummy_relying_party
    relying_party[:tos_uri] = 'http://example.com'
    assert_not relying_party.save
  end

  test "policy_uri_should_be_https" do
    relying_party = RelyingParty.new dummy_relying_party
    relying_party[:policy_uri] = 'http://example.com'
    assert_not relying_party.save
  end

  test "logo_uri_should_be_https" do
    relying_party = RelyingParty.new dummy_relying_party
    relying_party[:logo_uri] = 'http://example.com'
    assert_not relying_party.save
  end

  test "client_uri_should_be_https" do
    relying_party = RelyingParty.new dummy_relying_party
    relying_party[:client_uri] = 'http://example.com'
    assert_not relying_party.save
  end

  test "tos_uri_should_not_be_localhost" do
    relying_party = RelyingParty.new dummy_relying_party
    relying_party[:tos_uri] = 'https://localhost/index.html'
    assert_not relying_party.save
  end

  test "policy_uri_should_not_be_localhost" do
    relying_party = RelyingParty.new dummy_relying_party
    relying_party[:policy_uri] = 'https://localhost/index.html'
    assert_not relying_party.save
  end

  test "logo_uri_should_not_be_localhost" do
    relying_party = RelyingParty.new dummy_relying_party
    relying_party[:logo_uri] = 'https://localhost/index.html'
    assert_not relying_party.save
  end

  test "client_uri_should_not_be_localhost" do
    relying_party = RelyingParty.new dummy_relying_party
    relying_party[:client_uri] = 'https://localhost/index.html'
    assert_not relying_party.save
  end

  test "authorized_redirect_uri_should_return_true_if_authorized" do
    assert relying_parties(:example).authorized_redirect_uri? redirect_uris(:example).uri
  end

  test "authorized_redirect_uri_should_return_false_if_not_authorized" do
    assert_not relying_parties(:example).authorized_redirect_uri? 'https://not.authorized.com'
  end

  test "frontchannel_logout_uri_must_match_a_redirect_uri_domain_port-and_scheme" do
    relying_party = relying_parties(:example)
    relying_party.frontchannel_logout_uri = "#{relying_party.redirect_uris.first.uri}/logout"
    assert relying_party.save
    relying_party.frontchannel_logout_uri = 'https://notregistereduri.com/logout'
    assert_not relying_party.save
    relying_party.frontchannel_logout_uri = "#{relying_parties(:example2).redirect_uris.first.uri}/logout"
    assert_not relying_party.save
  end

  test "granted_scopes_method_should_return_all_scopes_a_user_granted_to_the_relying_party" do
    relying_party = relying_parties(:example)
    users().each do |user|
      granted_scopes = []
      user.sessions.each do |session|
        session.access_tokens.each do |access_token|
          granted_scopes << access_token.scopes.map { |scope| scope.name }
        end
      end
      assert_equal granted_scopes.flatten.uniq.sort, relying_party.granted_scopes(user)
    end
  end
end
