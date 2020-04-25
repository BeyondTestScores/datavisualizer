require "application_system_test_case"

class WarningsTest < ApplicationSystemTestCase

  test "warning is displayed for administrative measure that has a school_tree_category with missing nonlikert" do
    visit_admin admin_root_path

    incomplete_admin_measure = school_tree_categories(:administrative_measure2)
    assert_text "#{incomplete_admin_measure.name} is missing"

    click_on "Fix administrative measure >", match: :first

    fill_in "Nonlikert", with: "84"
    click_on "Update"

    click_on "Home", match: :first
    assert_no_text "#{incomplete_admin_measure.name} is missing"
  end

  test "warning is displayed for category that has no children, is not administrative, and has no questions" do
    visit_admin admin_root_path

    base_category_no_questions = categories(:four)
    warning_text= "#{base_category_no_questions.name} needs a subcategory, questions, or an administrative measure:"
    assert_text warning_text

    click_text "Fix category >", page.find(".missing .category-#{base_category_no_questions.id}")

    click_on "+ Add A Question To This Category"
    fill_in "Text", with: "Question?"
    fill_in "Option1", with: "Option1"
    fill_in "Option2", with: "Option2"
    fill_in "Option3", with: "Option3"
    fill_in "Option4", with: "Option4"
    fill_in "Option5", with: "Option5"
    click_on "Create"

    click_on "Home", match: :first
    assert_no_text warning_text
  end

end
