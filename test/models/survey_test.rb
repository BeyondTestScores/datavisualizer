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
  end

  test "survey monkey updated when question updated" do
  end

  test "survey monkey updated when question assigned to new category" do
  end

  test "survey monkey page doesn't exist" do

  end

  test "survey monkey question doesn't exist on page" do

  end

  test 'survey monkey times out' do
    # stub_request(:any, 'www.example.net').to_timeout
    flunk("test for survey monkey timing out")
  end

end
