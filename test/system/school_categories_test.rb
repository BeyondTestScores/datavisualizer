require "application_system_test_case"

class SchoolCategoriesTest < ApplicationSystemTestCase
  setup do
    @school_category = school_categories(:one)
  end

  # test "school category is automatically created with no nonlikert when adding an administrative measure" do
  #   flunk("Do it")
  # end
  #
  # test "updating a school category" do
  #   visit_admin admin_root_path
  #
  #
  #   fill_in "Nonlikert", with: @school_category.nonlikert
  #   click_on "Update"
  #
  #   assert_text "Administrative measure was successfully updated"
  # end
end
