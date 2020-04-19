require 'test_helper'

class Admin::SchoolCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school_category = school_categories(:one)
  end

  test "should get new" do
    get new_admin_school_category_url, headers: authorized_headers
    assert_response :success
  end

  test "should create school_category" do
    assert_difference('SchoolCategory.count') do
      post admin_school_categories_url, params: { school_category: { school_id: @school_category.school_id, category_id: @school_category.category_id, nonlikert: @school_category.nonlikert } }, headers: authorized_headers
    end

    assert_redirected_to admin_school_category_url(SchoolCategory.last)
  end

  test "should show school_category" do
    get admin_school_category_url(@school_category), headers: authorized_headers
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_school_category_url(@school_category), headers: authorized_headers
    assert_response :success
  end

  test "should update school_category" do
    patch admin_school_category_url(@school_category), params: { school_category: { nonlikert: @school_category.nonlikert } }, headers: authorized_headers
    assert_redirected_to admin_school_category_url(@school_category)
  end

  test "should destroy school_category" do
    assert_difference('SchoolCategory.count', -1) do
      delete admin_school_category_url(@school_category), headers: authorized_headers
    end

    assert_redirected_to admin_root_path
  end
end
