require 'test_helper'

class AuthorizationCodeScopeTest < ActiveSupport::TestCase

  def dummy_authorization_code_scope
    {
      scope: scopes(:example),
      authorization_code: authorization_codes(:example)
    }
  end

  test "scope_item_must_be_unique_in_authorization_code" do
    auth_scope = AuthorizationCodeScope.new dummy_authorization_code_scope
    assert_not auth_scope.save
    auth_scope.authorization_code = authorization_codes(:example2)
    assert auth_scope.save
  end

end
