require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  def dummy_company
    {
      name: 'Company A'
    }
  end

  test "should_create_valid_company" do
    company = Company.new dummy_company
    assert company.save
  end

  test "company_name_should_be_unique" do
    not_unique_name = dummy_company
    not_unique_name[:name] = 'Example'
    company = Company.new not_unique_name
    assert_not company.save
  end

  test "company_name_should_be_present" do
    name_not_present = dummy_company
    name_not_present[:name] = nil
    company = Company.new name_not_present
    assert_not company.save
  end

end
