require "application_system_test_case"

class SchoolsTest < ApplicationSystemTestCase
  setup do
    @school = schools(:one)
  end

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
    requests = []

    school = schools(:two)
    school.surveys.each do |survey|
      deleted_stcqs = []
      survey.school_tree_category_questions.each do |stcq|
        deleted_stcqs << stcq

        requests << survey_monkey_mock(
          method: :delete,
          url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}/questions/#{stcq.survey_monkey_id}"
        )

        requests << survey_monkey_mock(
          method: :get,
          url: "surveys/#{survey.survey_monkey_id}/details",
          responses: [
            details(
              survey: survey,
              survey_questions: survey.school_tree_category_questions - deleted_stcqs,
              pages: [
                {"id": stcq.survey_monkey_page_id, "title": stcq.category.name}
              ]
            )
          ]
        )

        requests << survey_monkey_mock(
          method: :delete,
          url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}"
        )
      end

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(
            survey: survey,
            default_page: false
          )
        ]
      )

      # requests << survey_monkey_mock(
      #   method: :delete,
      #   url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}"
      # )

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}"
      )

    end

    visit_admin admin_root_path
    click_on school.name, match: :first

    page.accept_confirm do
      click_on "Delete School", match: :first
    end

    assert_text "School was successfully destroyed"

    assert_requests requests
  end
end
