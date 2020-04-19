require 'test_helper'

class SchoolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school = schools(:one)
  end

  test "should get new" do
    get new_admin_school_url, headers: authorized_headers
    assert_response :success
  end

  test "should create school" do
    assert_difference('School.count') do
      post admin_schools_url, params: { school: { description: @school.description, name: @school.name } }, headers: authorized_headers
    end

    assert_redirected_to admin_school_url(School.last)
  end

  test "should show school" do
    get admin_school_url(@school), headers: authorized_headers
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_school_url(@school), headers: authorized_headers
    assert_response :success
  end

  test "should update school" do
    patch admin_school_url(@school), params: { school: { description: @school.description, name: @school.name } }, headers: authorized_headers
    assert_redirected_to admin_school_url(@school)
  end

  test "should destroy school" do
    assert_difference('School.count', -1) do
      delete admin_school_url(@school), headers: authorized_headers
    end

    assert_redirected_to admin_root_path
  end
end
