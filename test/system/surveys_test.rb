require "application_system_test_case"

class SurveysTest < ApplicationSystemTestCase
  setup do
    @survey = surveys(:one)
  end

  test "creating a Survey" do
    requests = []

    category = categories(:one)

    new_survey_name = "New Survey"
    new_survey_monkey_id = "SURVEY_MONKEY_ID"
    requests << survey_monkey_mock(
      method: :post,
      url: "surveys",
      body: {"title": new_survey_name},
      responses: [{"title": new_survey_name, "id": new_survey_monkey_id}]
    )

    q1 = "SURVEY_MONKEY_Q1"
    q1p = "SURVEY_MONKEY_Q1P"

    q2 = "SURVEY_MONKEY_Q2"
    q2p = "SURVEY_MONKEY_Q2P"

    new_survey = Survey.new(name: new_survey_name, survey_monkey_id: new_survey_monkey_id)
    new_sq1 = SurveyQuestion.new(question: questions(:one), survey_monkey_id: q1, survey_monkey_page_id: q1p)
    new_sq2 = SurveyQuestion.new(question: questions(:two), survey_monkey_id: q2, survey_monkey_page_id: q2p)
    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{new_survey_monkey_id}/details",
      responses: [
        details(survey: new_survey),
        details(survey: new_survey, survey_questions: [new_sq1]),
        details(survey: new_survey, survey_questions: [new_sq1, new_sq2])
      ],
      times: 3
    )

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{new_survey_monkey_id}/pages",
      responses: [
        {data: pages(default_page: true)},
        {data: pages(survey_questions: [new_sq1])}
      ],
      times: 2
    )

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys/#{new_survey_monkey_id}/pages",
      body: {title: categories(:one).name},
      responses: [{"id": q1p, title: categories(:one).name}]
    )

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys/#{new_survey_monkey_id}/pages/#{q1p}/questions",
      body: questions(:one).survey_monkey_structure,
      responses: [{"id": q1}]
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{new_survey_monkey_id}/pages/#{DEFAULT_PAGE_ID}"
    )

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys/#{new_survey_monkey_id}/pages",
      body: {title: categories(:two).name},
      responses: [{"id": q2p, title: categories(:two).name}]
    )

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys/#{new_survey_monkey_id}/pages/#{q2p}/questions",
      body: questions(:two).survey_monkey_structure,
      responses: [{"id": q2}]
    )

    visit_admin admin_root_path
    click_on "+ Create New Survey"

    fill_in "Name", with: new_survey_name
    click_text category.name

    category.all_questions.each { |q| assert check(q.text).checked? }

    click_on "Create"

    assert_text new_survey_name
    assert_text category.name
    category.all_questions.each { |q| assert_text q.text }

    assert_requests requests
  end

  test "updating a Survey" do
    requests = []

    existing_survey_name = @survey.name
    new_survey_name = "New Survey Name"

    initial_details = details(survey: @survey)
    @survey.update_column(:name, new_survey_name)
    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{@survey.survey_monkey_id}/details",
      responses: [
        initial_details,
        initial_details,
        details(survey: @survey)
      ],
      times: 3
    )

    requests << survey_monkey_mock(
      method: :patch,
      url: "surveys/#{@survey.survey_monkey_id}",
      body: {title: new_survey_name}
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{@survey.survey_monkey_id}/pages/#{DEFAULT_PAGE_ID}"
    )
    @survey.update_column(:name, existing_survey_name)

    visit_admin admin_root_path
    click_on @survey.name, match: :first

    click_on "Edit Survey"

    fill_in "Name", with: new_survey_name
    click_on "Update"

    assert_text "Survey was successfully updated"
    assert_text new_survey_name

    assert_requests requests
  end

  test "destroying a Survey" do
    requests = []

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{@survey.survey_monkey_id}/details",
      responses: [details(survey: @survey)]
    )

    requests << survey_monkey_mock(
      method: :delete,
      url: "surveys/#{@survey.survey_monkey_id}"
    )

    visit_admin admin_root_path

    click_on @survey.name, match: :first

    page.accept_confirm do
      click_on "Delete Survey", match: :first
    end

    assert_text "Survey was successfully destroyed"

    assert_requests requests
  end
end
