require 'test_helper'

class Admin::SurveysControllerTest < ActionDispatch::IntegrationTest

  def authorized_headers
    return {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }
  end

  def survey_monkey_mock(method: :get, url: "surveys", body: nil, response: {})
    with = {headers: {
      'Content-Type' => 'application/json',
      'Authorization' => "bearer #{Rails.application.credentials.dig(:surveymonkey)[:access_token]}"
    }}

    with[:body] = body.to_json if body != nil

    stub_request(method, "https://api.surveymonkey.com/v3/#{url}").with(with).
      to_return(status: 200, body: response.to_json, headers: {'Content-Type'=>'application/json'})
  end

  def test_authentication
    # get the admin page
    get "/admin/surveys/new"
    assert_equal 401, status

    # post the login and follow through to the home page
    get "/admin/surveys/new", headers: authorized_headers
    assert_equal "/admin/surveys/new", path
  end

  def test_new_has_form
    get "/admin/surveys/new", headers: authorized_headers
    assert_select "form"
    assert_select "input.form-check-input", Question.count
  end

  def test_create__requirements
    survey_name = "New Survey"
    survey_monkey_id = "SURVEY_MONKEY_ID"

    survey_monkey_mock(
      method: :post,
      url: "surveys",
      body: {"title": survey_name},
      response: {"title": survey_name, "id": survey_monkey_id}
    )
    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey_monkey_id}/details",
      response: {'title': survey_name}
    )
    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey_monkey_id}/pages"
    )

    survey_count = Survey.count
    post "/admin/questions", headers: authorized_headers
    assert_select "p", "Invalid Parameters"
    assert_equal survey_count, Survey.count

    post "/admin/surveys", headers: authorized_headers, params: {
      survey: {
        name: ""
      }
    }
    assert_select "li", "Name can't be blank"
    assert_equal survey_count, Survey.count

    survey = Survey.last
    post "/admin/surveys", headers: authorized_headers, params: {
      survey: {
        name: survey_name,
        question_ids: [Question.first.id, Question.last.id]
      }
    }
    assert_equal survey_count + 1, Survey.count
    assert_equal 302, status
    follow_redirect!

    survey = Survey.last
    assert_equal "/admin/surveys/#{survey.id}", path
    assert_equal 2, survey.questions.count
  end

  def test_show
    survey = surveys(:two)
    stub_request(:get, "https://api.surveymonkey.com/v3/surveys/#{survey.survey_monkey_id}/details").
      with(
        headers: {
      	  'Authorization'=>"bearer #{Rails.application.credentials.dig(:surveymonkey)[:access_token]}",
      	  'Content-Type'=>'application/json',
        }).
      to_return(status: 200, body: "", headers: {})

    get "/admin/surveys/#{survey.id}", headers: authorized_headers

    assert_select "h2", survey.name
    assert_select "a", survey.questions.first.text
  end

  test "should get edit" do
    survey = surveys(:two)
    get edit_admin_survey_url(survey), headers: authorized_headers
    assert_response :success
  end

  test "should update survey" do
    survey = surveys(:two)
    new_survey_name = "New Survey Name"

    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      response: {"title": new_survey_name}
    )

    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/pages"
    )

    survey_monkey_mock(
      method: :patch,
      url: "surveys/#{survey.survey_monkey_id}",
      body: {"title": "New Survey Name"}
    )

    patch admin_survey_url(survey), headers: authorized_headers, params: {
      survey: { name: new_survey_name, survey_monkey_id: survey.survey_monkey_id }
    }
    assert_redirected_to admin_survey_url(survey)
  end

  # test "should destroy survey" do
  #   survey = surveys(:two)
  #   assert_difference('Survey.count', -1) do
  #     delete admin_survey_url(survey), headers: authorized_headers
  #   end
  #
  #   assert_redirected_to surveys_url
  # end

end
