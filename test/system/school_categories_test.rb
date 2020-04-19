require "application_system_test_case"

class SchoolCategoriesTest < ApplicationSystemTestCase
  setup do
    @school_category = school_categories(:one)
  end

  test "school categories are automatically created with no nonlikert when adding an administrative measure" do
    visit_admin admin_root_path

    click_on "+ Create New Administrative Measure"

    assert_text 'Administrative Measure'

    measure_name = 'An Administrative Measure'
    fill_in 'Name', with: measure_name
    click_text categories(:one).name

    click_on 'Create'

    assert_text measure_name
    assert_text schools(:one).name
    assert_text schools(:two).name
  end

  test "updating a school category" do
    visit_admin admin_root_path

    administrative_measure = categories(:administrative_measure)
    click_text administrative_measure

    click_on school_categories(:administrative_measure).name(:school)

    fill_in "Nonlikert", with: 3
    click_on "Update"

    assert_text "#{school_categories(:administrative_measure).name(:school)} was successfully updated"

    assert_text "#{school_categories(:administrative_measure).name(:school)}: 3"
    assert_text administrative_measure.parent_category
  end
end
