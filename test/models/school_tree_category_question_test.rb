require 'test_helper'

class SchoolTreeCategoryQuestionTest < ActiveSupport::TestCase

  test "Adding first school_tree_category_question of a kind to a tree creates a survey of that kind with that question" do
    requests = []

    tree_category = tree_categories(:four)
    tree_survey_for_community_count = tree_category.tree.surveys.for_community.count

    question_for_community = Question.create(
      text: "Do you like this school?",
      option1: "Option 1",
      option2: "Option 2",
      option3: "Option 3",
      option4: "Option 4",
      option5: "Option 5",
      kind: Question.kinds[:for_community]
    )

    stc = tree_category.tree_category_questions.create(
      question: question_for_community
    )

    stcq = stc.school_tree_category_questions.new(
      school: schools(:one)
    )

    survey_monkey_id = "SURVEY_MONKEY_ID"
    survey_monkey_page_id = "SURVEY_MONKEY_PAGE_ID"
    survey_monkey_question_id = "SURVEY_MONKEY_QUESTION_ID"
    requests << survey_monkey_mock(
      method: :post,
      url: "surveys",
      body: {title: "2020-2021 For Community"},
      responses: [{"id": survey_monkey_id}]
    )

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys/#{survey_monkey_id}/pages",
      body: {title: tree_category.category.name},
      responses: [{"id": survey_monkey_page_id}]
    )

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey_monkey_id}/pages",
      responses: [{"data": [
        {"id": DEFAULT_PAGE_ID}
      ]}]
    )

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys/#{survey_monkey_id}/pages/#{survey_monkey_page_id}/questions",
      body: question_for_community.survey_monkey_structure,
      responses: [{"id": survey_monkey_question_id}]
    )

    stcq.survey_monkey_page_id = survey_monkey_page_id
    stcq.survey_monkey_id = survey_monkey_question_id
    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey_monkey_id}/details",
      responses: [
        details(
          survey: Survey.new(name: "#{tree_category.tree.name} For Community", survey_monkey_id: survey_monkey_id),
          survey_questions: [stcq]
        )
      ]
    )
    stcq.survey_monkey_page_id = nil
    stcq.survey_monkey_id = nil

    stcq.save

    assert_equal tree_survey_for_community_count + 1, tree_category.tree.surveys.for_community.count
    assert tree_category.tree.surveys.for_community.last.school_tree_category_questions.include?(stcq)

    assert_requests requests
  end

  test "adding a question of a kind where a survey already exists adds it to that survey" do
    requests = []

    survey = surveys(:one_students)
    school = schools(:one)
    tree_category = tree_categories(:one)
    tree_survey_for_students_count = tree_category.tree.surveys.for_students.count
    existing_stcq = school_tree_category_questions(:one)

    question_for_students = Question.create(
      text: "Do you like this school?",
      option1: "Option 1",
      option2: "Option 2",
      option3: "Option 3",
      option4: "Option 4",
      option5: "Option 5",
      kind: Question.kinds[:for_students]
    )

    stc = tree_category.tree_category_questions.create(
      question: question_for_students
    )

    stcq = stc.school_tree_category_questions.new(
      school: school
    )

    survey_monkey_question_id = "SURVEY_MONKEY_QUESTION_ID"
    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/pages",
      responses: [
        {"data": [
          {"id": existing_stcq.survey_monkey_page_id, "title": existing_stcq.category.name}
        ]}
      ]
    )

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{existing_stcq.survey_monkey_page_id}/questions",
      body: question_for_students.survey_monkey_structure,
      responses: [{"id": survey_monkey_question_id}]
    )

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [
        details(
          survey: survey,
          survey_questions: survey.school_tree_category_questions.to_a + [stcq]
        )
      ]
    )

    stcq.save

    assert_equal tree_survey_for_students_count, tree_category.tree.surveys.for_students.count
    assert tree_category.tree.surveys.for_school(school).for_students.first.school_tree_category_questions.include?(stcq)

    assert_requests requests
  end

end
