require 'test_helper'

class SurveyTest < ActiveSupport::TestCase

  test "survey monkey sync -- name change" do
    new_name = "A totally different name"
    survey = surveys(:one)

    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [{"title": survey.name}]
    )

    survey_monkey_mock(
      method: :patch,
      url: "surveys/#{survey.survey_monkey_id}",
      body: {"title": new_name}
    )

    survey.update(name: new_name)
    assert_equal new_name, survey.reload.name
  end

  test "survey monkey sync -- delete question" do
    survey = surveys(:two)

    # survey_monkey_mock(
    #   method: :get,
    #   url: "surveys/#{survey.survey_monkey_id}/details",
    #   responses: [{"title": survey.name}]
    # )

    survey.update(questions_ids: [questions(:two).id])
  end

end
