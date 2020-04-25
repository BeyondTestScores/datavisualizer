require 'test_helper'

class Admin::SchoolCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school_tree_category = school_tree_categories(:one)
  end

  test "should get new" do
    get new_admin_school_tree_category_url, headers: authorized_headers
    assert_response :success
  end

  test "should create school_tree_category" do
    assert_difference('SchoolTreeCategory.count') do
      post admin_school_tree_categories_url, params: { school_tree_category: { school_id: @school_tree_category.school_id, category_id: @school_tree_category.category_id, nonlikert: @school_tree_category.nonlikert } }, headers: authorized_headers
    end

    assert_redirected_to admin_school_tree_category_url(SchoolTreeCategory.last)
  end

  test "should show school_tree_category" do
    get admin_school_tree_category_url(@school_tree_category), headers: authorized_headers
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_school_tree_category_url(@school_tree_category), headers: authorized_headers
    assert_response :success
  end

  test "should update school_tree_category" do
    patch admin_school_tree_category_url(@school_tree_category), params: { school_tree_category: { nonlikert: @school_tree_category.nonlikert } }, headers: authorized_headers
    assert_redirected_to [:admin, @school_tree_category.category]
  end

  test "should destroy school_tree_category" do
    assert_difference('SchoolTreeCategory.count', -1) do
      delete admin_school_tree_category_url(@school_tree_category), headers: authorized_headers
    end

    assert_redirected_to admin_root_path
  end
end
