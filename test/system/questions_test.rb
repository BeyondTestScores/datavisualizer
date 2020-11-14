require "application_system_test_case"

class QuestionsTest < ApplicationSystemTestCase
  test "creating a question" do
    requests = []

    tree = trees(:one)
    category = categories(:four)
    tree_category = tree.tree_categories.for_category(category).first

    new_question = Question.new(
      text: "What is this question?",
      option1: "Option1",
      option2: "Option2",
      option3: "Option3",
      option4: "Option4",
      option5: "Option5",
      kind: :for_community
    )

    
    surveys = []
    School.all.each do |school|
      surveys << school.surveys.for_tree(tree_category.tree).new(
        name: "2020-2021 For Community",
        kind: :for_community,
        survey_monkey_id: "SURVEY_MONKEY_ID_#{school.id}"
      )
    end

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys",
      body: {"title": "#{tree.name} For Community"},
      responses: surveys.map { |s| {"id": s.survey_monkey_id } },
      times: 2
    )

    surveys.each do |survey|
      school = survey.school

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
        body: {"title": tree_category.name},
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
        tree_category_question: tree_category.tree_category_questions.new(
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

    visit_admin admin_root_path

    click_on tree.name
    click_on category.name

    click_on "+ Add A Question To This Category"

    fill_in "Text", with: new_question.text
    fill_in "Option 1", with: new_question.option1
    fill_in "Option 2", with: new_question.option2
    fill_in "Option 3", with: new_question.option3
    fill_in "Option 4", with: new_question.option4
    fill_in "Option 5", with: new_question.option5
    select "For Community", :from => "tree_category_question[question_attributes][kind]" 

    click_on "Create"

    assert_text "What is this question?"
    assert_text "Category: Category Four"

    assert_requests requests
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

    click_on trees(:one).name

    click_on tcq

    page.accept_confirm do
      click_on "Delete Question", match: :first
    end

    assert_text "Question was successfully destroyed"
    assert_no_text tcq.question.text

    assert_requests requests
  end
end
