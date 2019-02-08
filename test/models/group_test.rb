require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  def dummy_group
    {
      name: 'Group A',
      desc: 'Does example thing on example company',
      company: companies(:example)
    }
  end

  test "should_create_valid_group" do
    group = Group.new dummy_group
    assert group.save
  end

  test "group_name_should_be_unique_on_company_scope" do
    not_unique_group = dummy_group
    not_unique_group[:name] = 'Example'
    unique_group = not_unique_group.clone
    unique_group[:company] = companies(:example2)
    group1 = Group.new not_unique_group
    group2 = Group.new unique_group
    assert_not group1.save
    assert group2.save
  end

  test "group_name_should_be_present" do
    no_name = dummy_group
    no_name[:name] = nil
    group = Group.new no_name
    assert_not group.save
  end

  test "group_desc_should_be_present" do
    no_desc = dummy_group
    no_desc[:desc] = nil
    group = Group.new no_desc
    assert_not group.save
  end

  test "group_desc_should_have_at_least_10_characters" do
    short_desc = dummy_group
    short_desc[:desc] = 'aabc'
    group = Group.new
    assert_not group.save
  end

end
