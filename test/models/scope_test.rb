require 'test_helper'

class ScopeTest < ActiveSupport::TestCase

  def dummy_scope
    {
      name: 'email'
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


end
