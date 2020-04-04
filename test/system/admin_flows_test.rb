require "application_system_test_case"

class AdminFlowsTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit_admin admin_root_path

    assert_text "Admin Home"
  end
end
