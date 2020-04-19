require "application_system_test_case"

class SchoolCategoriesTest < ApplicationSystemTestCase
  setup do
    @school_category = school_categories(:one)
  end

  test "visiting the index" do
    visit school_categories_url
    assert_selector "h1", text: "School Categories"
  end

  test "creating a School category" do
    visit school_categories_url
    click_on "New School Category"

    fill_in "Answer index total", with: @school_category.answer_index_total
    fill_in "Category", with: @school_category.category
    fill_in "Nonlikert", with: @school_category.nonlikert
    fill_in "Response count", with: @school_category.response_count
    fill_in "School", with: @school_category.school
    fill_in "Year", with: @school_category.year
    fill_in "Zscore", with: @school_category.zscore
    click_on "Create School category"

    assert_text "School category was successfully created"
    click_on "Back"
  end

  test "updating a School category" do
    visit school_categories_url
    click_on "Edit", match: :first

    fill_in "Answer index total", with: @school_category.answer_index_total
    fill_in "Category", with: @school_category.category
    fill_in "Nonlikert", with: @school_category.nonlikert
    fill_in "Response count", with: @school_category.response_count
    fill_in "School", with: @school_category.school
    fill_in "Year", with: @school_category.year
    fill_in "Zscore", with: @school_category.zscore
    click_on "Update School category"

    assert_text "School category was successfully updated"
    click_on "Back"
  end

  test "destroying a School category" do
    visit school_categories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "School category was successfully destroyed"
  end
end
