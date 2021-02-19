require 'test_helper'

class SurveyTest < ActiveSupport::TestCase

  test "survey monkey sync -- deleted default survey monkey page" do
    requests = []
    survey = surveys(:one_teachers)

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [details(survey: survey, survey_questions: [])]
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{DEFAULT_PAGE_ID}"
    )

    survey.sync_with_survey_monkey

    assert_requests(requests)
  end

  test "survey monkey sync -- name change" do
    requests = []
    new_name = "A totally different name"
    survey = surveys(:one_students)

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [{"title": survey.name}]
    )

    requests << survey_monkey_mock(
      method: :patch,
      url: "surveys/#{survey.survey_monkey_id}",
      body: {"title": new_name}
    )

    survey.update(name: new_name)
    assert_equal new_name, survey.reload.name
    assert_requests(requests)
  end

  test "deleting question -- triggers delete of survey monkey_question" do
    requests = []
    survey = surveys(:one_students)
    sq = school_tree_category_questions(:one)

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{sq.survey_monkey_page_id}/questions/#{sq.survey_monkey_id}"
    )

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [
        details(survey: survey, survey_questions: [], pages: [{"id": sq.survey_monkey_page_id}])
      ],
      times: 1
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{sq.survey_monkey_page_id}"
    )

    assert_equal 1, survey.school_tree_category_questions.count
    sq.destroy
    assert_equal 0, survey.school_tree_category_questions.count
    assert_requests(requests)
  end

  test "survey monkey sync -- delete question" do
    requests = []
    survey = surveys(:one_teachers)
    deleted = school_tree_category_questions(:one)
    deleted.delete

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [details(survey: survey, survey_questions: [deleted, school_tree_category_questions(:two)])]
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{deleted.survey_monkey_page_id}/questions/#{deleted.survey_monkey_id}"
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{deleted.survey_monkey_page_id}"
    )

    survey.sync_with_survey_monkey
    assert_requests(requests)
  end

  test "survey monkey updated when category deleted (page and questions deleted on multiple surveys)" do
    requests = []
    category = categories(:one)

    stcqs = category.school_tree_category_questions
    assert_equal 2, stcqs.length

    stcqs.each do |stcq|
      survey = stcq.survey
      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}/questions/#{stcq.survey_monkey_id}"
      )

      remaining_stcqs = survey.school_tree_category_questions.select { |x| x.survey_monkey_id != stcq.survey_monkey_id}
      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(
            survey: survey,
            survey_questions: remaining_stcqs,
            pages: [{"id": stcq.survey_monkey_page_id}]
          )
        ]
      )

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}"
      )
    end

    category.destroy
    assert_requests(requests)
  end

  test "survey monkey updated when category renamed" do
    $survey_monkey_disabled = true
    
    requests = []

    tree_category = tree_categories(:two)
    
    existing_category_name = tree_category.category.name
    new_category_name = "New Category Name"

    tree_category.category.update_column('name', new_category_name)
    stcqs = tree_category.school_tree_category_questions
    stcqs.each do |stcq|
      survey = stcq.survey
      requests << survey_monkey_mock(
        method: :patch,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}",
        body: {"title": tree_category.category.name}
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(survey: survey)
        ]
      )
    end
    tree_category.category.update_column('name', existing_category_name)

    tree_category.category.update(name: new_category_name)

    assert_requests(requests)

    $survey_monkey_disabled = false
  end

  test "out of sync category name" do
    requests = []

    changed_on_survey_monkey = categories(:two)
    existing_name = changed_on_survey_monkey.name

    changed_on_survey_monkey.all_school_tree_category_questions.each do |stcq|
      survey = stcq.survey

      changed_on_survey_monkey.update_column('name', "CHANGED CATEGORY NAME")
      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [details(survey: survey)]
      )
      changed_on_survey_monkey.update_column('name', existing_name)

      requests << survey_monkey_mock(
        method: :patch,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}",
        body: {"title": existing_name}
      )

      survey.sync_with_survey_monkey
    end

    assert_requests(requests)
  end

  test "survey monkey updated when question updated" do
    requests = []

    question = questions(:two_teacher)

    existing_text = question.text
    new_text = "New text"

    question.update_column('text', new_text)
    question.tree_category_questions.each do |tcq|
      tcq.school_tree_category_questions.each do |stcq|
        survey = stcq.survey

        requests << survey_monkey_mock(
          method: :patch,
          url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}/questions/#{stcq.survey_monkey_id}",
          body: stcq.question.survey_monkey_structure(1)
        )

        requests << survey_monkey_mock(
          method: :get,
          url: "surveys/#{survey.survey_monkey_id}/details",
          responses: [details(survey: survey)]
        )
      end
    end
    question.update_column('text', existing_text)

    question.update(text: new_text)

    assert_requests(requests)
  end

  test "survey monkey updated when question assigned to new category" do
    requests = []

    tcq = tree_category_questions(:one)

    existing_tree_category = tcq.tree_category
    existing_tree_category_id = existing_tree_category.id
    new_tree_category = tree_categories(:two)
    new_tree_category_id = new_tree_category.id

    assert new_tree_category_id != existing_tree_category_id

    tcq.update_column('tree_category_id', new_tree_category_id)
    tcq.school_tree_category_questions.each do |stcq|
      survey = stcq.survey

      existing_page_id = stcq.survey_monkey_page_id
      new_page_id = "NEW_PAGE_ID"

      stcq.update_column(:survey_monkey_page_id, new_page_id)

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{existing_page_id}/questions/#{stcq.survey_monkey_id}"
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/pages",
        responses: [
          {"data": [{"id": existing_page_id, "title": existing_tree_category.category.name}]}
        ]
      )

      requests << survey_monkey_mock(
        method: :post,
        url: "surveys/#{survey.survey_monkey_id}/pages",
        body: {"title": new_tree_category.category.name},
        responses: [{"id": new_page_id}]
      )

      requests << survey_monkey_mock(
        method: :post,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{new_page_id}/questions",
        body: stcq.question.survey_monkey_structure(1),
        responses: [{
          "id": "QUESTION_ID", 
          "answers": {
            "choices": [{"id": 1}, {"id": 2}, {"id": 3}, {"id": 4}, {"id": 5}]
          }
        }]
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(survey: survey, pages: [{"id": existing_page_id, "title": existing_tree_category.category.name}])
        ]
      )

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{existing_page_id}"
      )
      stcq.update_column(:survey_monkey_page_id, existing_page_id)
    end
    tcq.update_column('tree_category_id', existing_tree_category_id)

    tcq.update(tree_category_id: new_tree_category_id)

    assert_requests requests
  end

  test "survey monkey page doesn't exist" do
    requests = []

    survey = surveys(:one_teachers)

    page_on_sm_not_local = "PAGE_ON_SM_NOT_LOCAL"

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [
        details(survey: survey, pages: [{"id": page_on_sm_not_local, "title": page_on_sm_not_local}])
      ]
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{page_on_sm_not_local}"
    )

    survey.sync_with_survey_monkey

    assert_requests requests
  end

  test "survey monkey question doesn't exist on page" do
    requests = []

    survey = surveys(:one_teachers)
    stcqs = survey.school_tree_category_questions.to_a

    question_on_sm_not_local = "QUESTION_ON_SM_NOT_LOCAL"
    page_id = stcqs.first.survey_monkey_page_id
    tree_category = stcqs.first.tree_category_question.tree_category

    stcqs << SchoolTreeCategoryQuestion.new(
      "survey_monkey_id": question_on_sm_not_local,
      "survey_monkey_page_id": page_id,
      tree_category_question: TreeCategoryQuestion.new(tree_category: tree_category, question: Question.new(text: "Question"))
    )

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [
        details(survey: survey, survey_questions: stcqs)
      ]
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{page_id}/questions/#{question_on_sm_not_local}"
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{page_id}"
    )

    survey.sync_with_survey_monkey

    assert_requests requests
  end

  test "create responses" do
    requests = []

    survey = surveys(:one_teachers)
    stcq = survey.school_tree_category_questions.first

    respondent1_id = "RESPONDENT1_ID"
    response1_id = "RESPONSE1_ID"

    respondent2_id = "RESPONDENT2_ID"
    response2_id = "RESPONSE2_ID"

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/responses/#{response1_id}/details",
      responses: [
        {
          "pages": [
            {
              "id": stcq.survey_monkey_page_id, 
              "questions": [{
                "id": stcq.survey_monkey_id,
                "answers": [
                  "choice_id": "3"
                ]
              }]              
            }
          ]
        }
      ]
    )

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/responses/#{response2_id}/details",
      responses: [
        {
          "pages": [
            {
              "id": stcq.survey_monkey_page_id, 
              "questions": [{
                "id": stcq.survey_monkey_id,
                "answers": [
                  "choice_id": "2"
                ]
              }]              
            }
          ]
        }
      ]
    )

    survey.create_survey_responses(respondent1_id, response1_id)
    survey.create_survey_responses(respondent2_id, response2_id)

    response1 = survey.responses.where(
      school_tree_category_question_id: stcq.id,
      survey_monkey_response_id: response1_id
    ).first

    assert_equal 3, response1.option
    assert_equal respondent1_id, response1.survey_monkey_respondent_id
    assert_equal response1_id, response1.survey_monkey_response_id

    response2 = survey.responses.where(
      school_tree_category_question_id: stcq.id,
      survey_monkey_response_id: response2_id
    ).first

    assert_equal 2, response2.option
    assert_equal respondent2_id, response2.survey_monkey_respondent_id
    assert_equal response2_id, response2.survey_monkey_response_id

    assert_equal 5, stcq.reload.responses_sum
    assert_equal 2, stcq.reload.responses_count

    assert_equal 5, stcq.school_tree_category.responses_sum
    assert_equal 2, stcq.school_tree_category.responses_count

    assert_requests requests
  end

  # test 'survey monkey times out' do
  #   requests = []
  #
  #   survey = surveys(:two)
  #
  #   survey_monkey_mock(
  #     method: :get,
  #     url: "surveys/#{survey.survey_monkey_id}/details",
  #     times_out: true
  #   )
  #
  #   survey.sync_with_survey_monkey
  #
  #   assert_requests requests
  # end

end
