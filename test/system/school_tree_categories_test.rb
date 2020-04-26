require "application_system_test_case"

class SchoolTreeCategoriesTest < ApplicationSystemTestCase
  setup do
    @school_tree_category = school_tree_categories(:one)
  end

  test "school categories are automatically created with no nonlikert when adding an administrative measure" do
    visit_admin admin_root_path

    click_on trees(:one)

    click_on categories(:one)

    click_on "+ Add An Administrative Measure To This Category"

    assert_text 'Administrative Measure'

    measure_name = 'An Administrative Measure'
    fill_in 'Name', with: measure_name

    click_on 'Create'

    assert_text measure_name
    assert_text schools(:one).name
    assert_text schools(:two).name
  end

  test "updating a school category" do
    visit_admin admin_root_path

    click_on trees(:one)

    administrative_measure = tree_categories(:administrative_measure)
    click_text administrative_measure

    click_on 'edit', match: :first

    fill_in "Nonlikert", with: 3
    click_on "Update"

    assert_text "#{school_tree_categories(:administrative_measure).name(:school)} was successfully updated"

    assert_text "#{school_tree_categories(:administrative_measure).name(:school)}: 3"
    assert_text administrative_measure.parent_tree_category
  end
end
