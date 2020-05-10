require 'test_helper'

class Admin::SchoolsControllerTest < ActionDispatch::IntegrationTest
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
    requests = []

    @school.surveys.each do |survey|
      deleted_stcqs = []
      survey.school_tree_category_questions.each do |stcq|
        deleted_stcqs << stcq

        requests << survey_monkey_mock(
          method: :delete,
          url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}/questions/#{stcq.survey_monkey_id}",
          times: 2
        )

        requests << survey_monkey_mock(
          method: :get,
          url: "surveys/#{survey.survey_monkey_id}/details",
          responses: [
            details(survey: survey, survey_questions: survey.school_tree_category_questions - [deleted_stcqs])
          ]
        )

        requests << survey_monkey_mock(
          method: :delete,
          url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}"
        )
      end

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}"
      )
    end

    assert_difference('School.count', -1) do
      delete admin_school_url(@school), headers: authorized_headers
    end

    assert_redirected_to admin_root_path

    assert_requests requests
  end
end
