require "application_system_test_case"

class SchoolsTest < ApplicationSystemTestCase
  setup do
    @school = schools(:one)
  end

  # test "visiting the index" do
  #   visit schools_url
  #   assert_selector "h1", text: "Schools"
  # end

  test "creating a School" do
    visit_admin admin_root_path
    click_on "+ Create New School"

    # fill_in "Description", with: @school.description
    fill_in "Name", with: @school.name
    click_on "Create"

    assert_text "School was successfully created"
  end

  test "updating a School" do
    visit_admin admin_root_path
    click_on schools(:two).name, match: :first

    click_on "Edit School", match: :first

    fill_in "Name", with: @school.name
    click_on "Update"

    assert_text "School was successfully updated"
  end

  test "destroying a School" do
    visit_admin admin_root_path
    click_on schools(:two).name, match: :first

    page.accept_confirm do
      click_on "Delete School", match: :first
    end

    assert_text "School was successfully destroyed"
  end
end
