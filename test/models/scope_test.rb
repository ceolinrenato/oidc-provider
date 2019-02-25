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
    scope.name = scopes(:example).name
    assert_not scope.save
  end

  test "test_scope_list_method" do
    list = Scope::scope_list
    assert_equal list, [scopes(:example).name, scopes(:example2).name].sort
  end


end
