require "application_system_test_case"

class QuestionsTest < ApplicationSystemTestCase
  test "creating a question" do
    visit_admin admin_root_path

    click_on trees(:one)
    click_on categories(:four)

    click_on "+ Add A Question To This Category"

    fill_in "Text", with: "What is this question?"
    fill_in "Option1", with: "An Option 1"
    fill_in "Option2", with: "An Option 2"
    fill_in "Option3", with: "An Option 3"
    fill_in "Option4", with: "An Option 4"
    fill_in "Option5", with: "An Option 5"

    click_on "Create"

    assert_text "What is this question?"
    assert_text "Category: Category Four"
  end

  test "deleting a question" do
    requests = []

    tcq = tree_category_questions(:two)

    tcq.school_tree_category_questions.each do |stcq|
      survey = stcq.survey
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
            survey_questions: survey.school_tree_category_questions - [stcq],
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

    visit_admin admin_root_path

    click_on trees(:one)

    click_on tcq

    page.accept_confirm do
      click_on "Delete Question", match: :first
    end

    assert_text "Question was successfully destroyed"
    assert_no_text tcq.question.text

    assert_requests requests
  end
end
