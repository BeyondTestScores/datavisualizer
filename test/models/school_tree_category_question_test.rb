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

    tcq = tree_category.tree_category_questions.new(
      question: question_for_community
    )

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys",
      body: {title: "2020-2021 For Community"},
      responses: School.all.map { |school| {"id": "SURVEY_MONKEY_ID_#{school.id}"} },
      times: 2
    )

    School.all.each do |school|
      survey_monkey_id = "SURVEY_MONKEY_ID_#{school.id}"
      survey_monkey_page_id = "SURVEY_MONKEY_PAGE_ID_#{school.id}"
      survey_monkey_question_id = "SURVEY_MONKEY_QUESTION_ID_#{school.id}"

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
        responses: [{
          "id": survey_monkey_question_id, 
          "answers": {
            "choices": [{"id": 1}, {"id": 2}, {"id": 3}, {"id": 4}, {"id": 5}]
          }
        }]
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey_monkey_id}/details",
        responses: [
          details(
            survey: Survey.new(name: "#{tree_category.tree.name} For Community", survey_monkey_id: survey_monkey_id),
            survey_questions: [school.school_tree_category_questions.new(
              tree_category_question: tcq,
              survey_monkey_page_id: survey_monkey_page_id,
              survey_monkey_id: survey_monkey_question_id
            )]
          )
        ]
      )
    end

    tcq.save

    assert_equal tree_survey_for_community_count + School.count, tree_category.tree.surveys.for_community.count
    School.all.each do |school|
      survey = school.surveys.for_community.first
      assert survey.school_tree_category_questions.for_question(question_for_community).present?
    end

    assert_requests requests
  end

  test "adding a question of a kind where a survey already exists adds it to that survey" do
    requests = []

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

    tcq = tree_category.tree_category_questions.new(
      question: question_for_students
    )

    School.all.each do |school|
      survey = school.surveys.for_tree(tree_category.tree).for_kind(question_for_students.kind).first

      stcq = tcq.school_tree_category_questions.new(
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
        responses: [{
          "id": survey_monkey_question_id, 
          "answers": {
            "choices": [{"id": 1}, {"id": 2}, {"id": 3}, {"id": 4}, {"id": 5}]
          }
        }]
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(
            survey: survey,
            survey_questions: survey.school_tree_category_questions
          )
        ]
      )
    end

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/surveymonkeyid2students/pages/#{DEFAULT_PAGE_ID}",
    )

    tcq.save

    assert_equal tree_survey_for_students_count, tree_category.tree.surveys.for_students.count

    School.all.each do |school|
      survey = tree_category.tree.surveys.for_school(school).for_students.first
      stcq = survey.school_tree_category_questions.for_question(question_for_students).first
      assert stcq.present?
      assert_equal stcq.survey_monkey_option1_id, "1"
      assert_equal stcq.survey_monkey_option2_id, "2"
      assert_equal stcq.survey_monkey_option3_id, "3"
      assert_equal stcq.survey_monkey_option4_id, "4"
      assert_equal stcq.survey_monkey_option5_id, "5"
    end

    assert_requests requests
  end

end
