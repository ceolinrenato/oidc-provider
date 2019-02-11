require 'test_helper'

class RedirectUriTest < ActiveSupport::TestCase

  def dummy_redirect_uri
    {
      uri: 'http://localhost:3001',
      relying_party: relying_parties(:example)
    }
  end

  test "should_create_valid_redirect_uri" do
    redirect_uri = RedirectUri.new dummy_redirect_uri
    assert redirect_uri.save
  end

  test "redirect_uri_should_be_https_if_not_localhost" do
    redirect_uri = RedirectUri.new dummy_redirect_uri
    redirect_uri[:uri] = 'http://example.com'
    assert_not redirect_uri.save
    redirect_uri[:uri] = 'https://example.com'
    assert redirect_uri.save
  end

  test "redirect_uri_should_be_unique_in_relying_party" do
    redirect_uri = RedirectUri.new dummy_redirect_uri
    redirect_uri[:uri] = 'http://localhost:3000'
    assert_not redirect_uri.save
  end

end
