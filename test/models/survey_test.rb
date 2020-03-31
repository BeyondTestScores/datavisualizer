require 'test_helper'

class SurveyTest < ActiveSupport::TestCase

  test "survey monkey sync -- deleted default survey monkey page" do
    requests = []
    survey = surveys(:two)

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
    survey = surveys(:one)

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
    survey = surveys(:two)
    sq = survey_questions(:one)

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{sq.survey_monkey_page_id}/questions/#{sq.survey_monkey_id}"
    )

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [details(survey: survey, survey_questions: [survey_questions(:two)])],
      times: 2
    )

    survey.update(question_ids: [questions(:two).id])
    assert_requests(requests)
  end

  test "survey monkey sync -- delete question" do
    requests = []
    survey = surveys(:two)
    deleted = survey_questions(:one)
    deleted.delete

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [details(survey: survey, survey_questions: [deleted, survey_questions(:two)])]
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
    category = categories(:two)
    SurveyQuestion.skip_callback(:commit, :after, :create_survey_monkey, raise: false)
    surveys(:one).survey_questions.create!(
      question: questions(:two),
      survey_monkey_id: "QUESTION_TWO_SURVEY_ONE_SURVEY_MONKEY",
      survey_monkey_page_id: "PAGE_QUESTION_TWO_SURVEY_ONE_SURVEY_MONKEY"
    )

    survey_questions = category.questions.map(&:survey_questions).flatten
    assert_equal 2, survey_questions.length

    survey_questions.each do |sq|
      survey = sq.survey
      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{sq.survey_monkey_page_id}/questions/#{sq.survey_monkey_id}"
      )

      remaining_survey_questions = survey.survey_questions.select { |x| x.survey_monkey_id != sq.survey_monkey_id}
      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(
            survey: survey,
            survey_questions: remaining_survey_questions,
            pages: [{"id": sq.survey_monkey_page_id}]
          )
        ]
      )

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{sq.survey_monkey_page_id}"
      )
    end

    category.destroy
    assert_requests(requests)

    SurveyQuestion.set_callback(:commit, :after, :create_survey_monkey)
  end

  test "survey monkey updated when category renamed" do
    requests = []

    category = categories(:two)
    SurveyQuestion.skip_callback(:commit, :after, :create_survey_monkey, raise: false)
    surveys(:one).survey_questions.create!(
      question: questions(:two),
      survey_monkey_id: "QUESTION_TWO_SURVEY_ONE_SURVEY_MONKEY",
      survey_monkey_page_id: "PAGE_QUESTION_TWO_SURVEY_ONE_SURVEY_MONKEY"
    )

    existing_category_name = category.name
    new_category_name = "New Category Name"

    category.update_column('name', new_category_name)
    survey_questions = category.questions.map(&:survey_questions).flatten
    survey_questions.each do |sq|
      survey = sq.survey
      requests << survey_monkey_mock(
        method: :patch,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{sq.survey_monkey_page_id}",
        body: {"title": category.name}
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(survey: survey)
        ]
      )
    end
    category.update_column('name', existing_category_name)

    category.update(name: new_category_name)

    assert_requests(requests)

    SurveyQuestion.set_callback(:commit, :after, :create_survey_monkey)
  end

  test "out of sync category name" do
    requests = []

    changed_on_survey_monkey = categories(:two)
    existing_name = changed_on_survey_monkey.name

    changed_on_survey_monkey.questions.each do |question|
      question.survey_questions.each do |survey_question|
        survey = survey_question.survey

        changed_on_survey_monkey.update_column('name', "CHANGED CATEGORY NAME")
        requests << survey_monkey_mock(
          method: :get,
          url: "surveys/#{survey.survey_monkey_id}/details",
          responses: [details(survey: survey)]
        )
        changed_on_survey_monkey.update_column('name', existing_name)

        requests << survey_monkey_mock(
          method: :patch,
          url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_question.survey_monkey_page_id}",
          body: {"title": existing_name}
        )

        survey.sync_with_survey_monkey
      end
    end

    assert_requests(requests)
  end

  test "survey monkey updated when question updated" do
    requests = []

    question = questions(:two)

    existing_text = question.text
    new_text = "New text"

    question.update_column('text', new_text)
    question.survey_questions.each do |survey_question|
      survey = survey_question.survey

      requests << survey_monkey_mock(
        method: :patch,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_question.survey_monkey_page_id}/questions/#{survey_question.survey_monkey_id}",
        body: survey_question.question.survey_monkey_structure(1)
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [details(survey: survey)]
      )
    end
    question.update_column('text', existing_text)

    question.update(text: new_text)

    assert_requests(requests)
  end

  test "survey monkey updated when question assigned to new category" do
    requests = []

    question = questions(:one)

    existing_category = question.category
    existing_category_id = existing_category.id
    new_category = categories(:two)
    new_category_id = new_category.id

    assert new_category_id != existing_category_id

    question.update_column('category_id', new_category_id)
    question.survey_questions.each do |survey_question|
      survey = survey_question.survey

      existing_page_id = survey_question.survey_monkey_page_id
      new_page_id = "NEW_PAGE_ID"

      survey_question.update_column(:survey_monkey_page_id, new_page_id)

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{existing_page_id}/questions/#{survey_question.survey_monkey_id}"
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/pages",
        responses: [
          {"data": [{"id": existing_page_id, "title": existing_category.name}]}
        ]
      )

      requests << survey_monkey_mock(
        method: :post,
        url: "surveys/#{survey.survey_monkey_id}/pages",
        body: {"title": new_category.name},
        responses: [{"id": new_page_id}]
      )

      requests << survey_monkey_mock(
        method: :post,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{new_page_id}/questions",
        body: question.survey_monkey_structure(1)
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(survey: survey, pages: [{"id": existing_page_id, "title": existing_category.name}])
        ]
      )

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{existing_page_id}"
      )
      survey_question.update_column(:survey_monkey_page_id, existing_page_id)
    end
    question.update_column('category_id', existing_category_id)

    question.update(category_id: new_category_id)

    assert_requests requests
  end

  test "survey monkey page doesn't exist" do
    requests = []

    survey = surveys(:two)

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

    survey = surveys(:two)

    question_on_sm_not_local = "QUESTION_ON_SM_NOT_LOCAL"
    page_id = survey_questions.first.survey_monkey_page_id
    category = survey_questions.first.question.category

    survey_questions = survey.survey_questions.to_a
    survey_questions << SurveyQuestion.new(
      "survey_monkey_id": question_on_sm_not_local,
      "survey_monkey_page_id": page_id,
      question: Question.new(category: category)
    )

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [
        details(survey: survey, survey_questions: survey_questions)
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
