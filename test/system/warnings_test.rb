require "application_system_test_case"

class WarningsTest < ApplicationSystemTestCase

  test "warning is displayed for administrative measure that has a school_tree_category with missing nonlikert" do
    visit_admin admin_root_path

    incomplete_admin_measure = school_tree_categories(:administrative_measure2)
    assert_text "#{incomplete_admin_measure.name} is missing"

    click_on "Fix administrative measure >", match: :first

    fill_in "Nonlikert", with: "84"
    click_on "Update"

    click_on "Home", match: :first
    assert_no_text "#{incomplete_admin_measure.name} is missing"
  end

  test "warning is displayed for category that has no children, is not administrative, and has no questions" do
    requests = []

    visit_admin admin_root_path

    base_tree_category_no_questions = tree_categories(:four)
    warning_text= "#{base_tree_category_no_questions.name} needs a subcategory, questions, or an administrative measure:"
    assert_text warning_text

    new_question = Question.new(
      text: "Question?",
      option1: "Option1",
      option2: "Option2",
      option3: "Option3",
      option4: "Option4",
      option5: "Option5",
      kind: :for_students
    )

    School.all.each do |school|
      survey = school.surveys.for_tree(base_tree_category_no_questions.tree).for_kind(:for_students).first

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/pages",
        responses: [
          {"data": survey.school_tree_category_questions.map { |stcq| {"id": stcq.survey_monkey_page_id} }.uniq}
        ]
      )

      survey_monkey_page_id = "SURVEY_MONKEY_PAGE_ID"
      requests << survey_monkey_mock(
        method: :post,
        url: "surveys/#{survey.survey_monkey_id}/pages",
        body: {"title": base_tree_category_no_questions.name},
        responses: [{"id": survey_monkey_page_id}]
      )

      survey_monkey_question_id = "SURVEY_MONKEY_QUESTION_ID"
      requests << survey_monkey_mock(
        method: :post,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_monkey_page_id}/questions",
        body: new_question.survey_monkey_structure,
        responses: [{"id": survey_monkey_question_id}]
      )

      survey.school_tree_category_questions.new(
        tree_category_question: base_tree_category_no_questions.tree_category_questions.new(
          question: new_question
        ),
        survey_monkey_id: survey_monkey_question_id,
        survey_monkey_page_id: survey_monkey_page_id
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [details(survey: survey)]
      )

    end

    click_text "Fix category >", page.find(".missing .tree-category-#{base_tree_category_no_questions.id}")

    click_on "+ Add A Question To This Category"
    fill_in "Text", with: new_question.text
    fill_in "Option1", with: new_question.option1
    fill_in "Option2", with: new_question.option2
    fill_in "Option3", with: new_question.option3
    fill_in "Option4", with: new_question.option4
    fill_in "Option5", with: new_question.option5
    select "For Students", :from => "tree_category_question[question_attributes][kind]" 
    click_on "Create"

    click_on "Home", match: :first
    assert_no_text warning_text

    assert_requests requests
  end

end
