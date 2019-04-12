require 'test_helper'

class ScopeTest < ActiveSupport::TestCase

  def dummy_scope
    {
      name: 'list_company_users'
    }
  end

  test "should_create_valid_scope" do
    scope = Scope.new dummy_scope
    assert scope.save
  end

  test "scope_names_must_be_present" do
    scope = Scope.new dummy_scope
    scope.name = nil
    assert_not scope.save
  end

  test "scope_names_should_be_unique" do
    scope = Scope.new dummy_scope
    scope.name = scopes().first.name
    assert_not scope.save
  end

  test "test_scope_list_method" do
    list = Scope::scope_list
    assert_equal list, OIDC_PROVIDER_CONFIG[:scopes].sort
  end

  test "test_parse_scope_method" do
    request_scope = "#{OIDC_PROVIDER_CONFIG[:scopes].join(' ')} abcdfqw"
    assert_equal Scope::parse_authorization_scope(request_scope), Scope::scope_list
  end

  test "test_invalid_scope_format" do
    request_scope = "openid $%*("
    assert_raises(CustomExceptions::InvalidRequest) { Scope::parse_authorization_scope(request_scope) }
  end

  test "test_empty_scope" do
    request_scope = nil
    assert_equal Scope::parse_authorization_scope(request_scope), []
  end

end
