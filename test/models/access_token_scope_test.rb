require 'test_helper'

class AccessTokenScopeTest < ActiveSupport::TestCase
  def example_access_token_scope
    {
      scope: scopes(:scope_openid),
      access_token: access_tokens(:example)
    }
  end

  test 'scope_item_must_be_unique_in_access_token' do
    access_token_scope = AccessTokenScope.new example_access_token_scope
    assert_not access_token_scope.save
    access_token_scope.access_token = access_tokens(:example2)
    assert access_token_scope.save
  end
end
