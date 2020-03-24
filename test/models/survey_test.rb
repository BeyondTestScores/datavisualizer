require 'test_helper'

class SurveyTest < ActiveSupport::TestCase

  DEFAULT_PAGE_ID = 'DEFAULT'

  test "survey monkey sync -- deleted default survey monkey page" do
    requests = []
    survey = surveys(:two)

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [details(survey: survey, survey_questions: survey.survey_questions)]
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

    survey.sync_with_survey_monkey
    assert_requests(requests)
  end

  test "survey monkey updated when category deleted (page and questions deleted)" do
    requests = []
    survey = surveys(:two)
    category = categories(:two)
    survey_questions = category.questions.map { |q| q.survey_questions.for(survey) }.flatten

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_questions.first.survey_monkey_page_id}"
    )

    survey_questions.each do |sq|
      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{sq.survey_monkey_page_id}/questions/#{sq.survey_monkey_id}"
      )
    end

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [details(survey: survey)]
    )

    category.destroy
    assert_requests(requests)
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
    assert false
  end

  def details(survey: nil, survey_questions: [], default_page: false)
    return {} if survey.nil?
    result = {"id": survey.survey_monkey_id, "title": survey.name}

    pages = []
    if default_page || survey_questions.empty?
      pages << {"id": DEFAULT_PAGE_ID, "title": ""}
    end

    survey_questions.each do |survey_question|
        page_id = survey_question.survey_monkey_page_id
        id = survey_question.survey_monkey_id
        question = survey_question.question
        page_title = question.category.name

        index = pages.index { |p| p["id"] == page_id }
        if index.nil?
          pages << {"id": page_id, "title": page_title, 'questions': []}
          index = pages.length - 1
        end

        pages[index][:questions] << {
          "id": id,
          "headings": [{
            "heading": question.text
          }],
          "answers": {
            "choices": [
              {"text": question.option1},
              {"text": question.option2},
              {"text": question.option3},
              {"text": question.option4},
              {"text": question.option5}
            ]
          }
        }
    end

    result["pages"] = pages

    return result
  end

end
