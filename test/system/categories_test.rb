require "application_system_test_case"

class CategoriesTest < ApplicationSystemTestCase
  test "creating a category" do
    visit_admin admin_root_path

    click_on "+ Create New Category"

    fill_in "Name", with: "Category Name"
    click_text "Category Four"

    click_on "Create"

    assert_text "Category Name"
    assert_text "Parent Category: Category Four"
  end

  test "creating an administrative measure" do
    visit_admin admin_root_path

    click_text categories(:four).name

    click_on "+ Add An Administrative Measure To This Category"

    admin_measure_name = "New Admin Measure"
    fill_in "Name", with: admin_measure_name

    click_on "Create"

    assert_text admin_measure_name
    assert_text categories(:four).name

    School.all.each do |school|
      assert_text school.name
    end

    assert_no_text "+ Add A Category Under This Category"
    assert_no_text "+ Add A Question To This Category"
    assert_no_text "+ Add An Administrative Measure To This Category"
  end

  test "deleting a category" do
    requests = []

    category = categories(:two)

    all_questions = category.all_questions
    all_survey_questions = all_questions.map(&:survey_questions).flatten.uniq
    deleted_survey_questions = []
    all_survey_questions.each do |survey_question|
      deleted_survey_questions << survey_question
      survey = survey_question.survey

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_question.survey_monkey_page_id}/questions/#{survey_question.survey_monkey_id}"
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(
            survey: survey,
            survey_questions: survey.survey_questions - deleted_survey_questions,
            pages: [{"id": survey_question.survey_monkey_page_id, "title": category.name}]
          )
        ]
      )

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_question.survey_monkey_page_id}"
      )

    end

    visit_admin admin_root_path

    click_on category.name

    page.accept_confirm do
      click_on "Delete Category", match: :first
    end

    assert_text "Category was successfully destroyed"
    assert_no_text category.name
    category.questions.each do |question|
      assert_no_text question.text
    end

    assert_requests requests
  end
end
