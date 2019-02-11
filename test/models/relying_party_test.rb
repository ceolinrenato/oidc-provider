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

end
