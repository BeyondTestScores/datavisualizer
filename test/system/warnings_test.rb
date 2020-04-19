require "application_system_test_case"

class WarningsTest < ApplicationSystemTestCase

  test "warning is displayed for administrative measure that has a school_category with missing nonlikert" do
    visit_admin admin_root_path

    incomplete_admin_measure = school_categories(:administrative_measure2)
    assert_text "#{incomplete_admin_measure.name} is missing"

    click_on "Fix it >", match: :first

    fill_in "Nonlikert", with: "84"
    click_on "Update"

    click_on "Home", match: :first
    assert_no_text "#{incomplete_admin_measure.name} is missing"
  end

end
