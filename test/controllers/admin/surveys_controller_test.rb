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
    survey_name = "New Survey For Test"
    survey_monkey_id = "SURVEY_MONKEY_ID"

    survey_monkey_mock(
      method: :post,
      url: "surveys",
      body: {"title": survey_name},
      responses: [{"title": survey_name, "id": survey_monkey_id}]
    )

    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey_monkey_id}/details",
      responses: [{'title': survey_name}]
    )

    question1 = questions(:one)
    question1_id = "ID_FOR_QUESTION1_#{question1.id}"

    question2 = questions(:two)
    question2_id = "ID_FOR_QUESTION2_#{question2.id}"

    default_page = "DEFAULT_PAGE" #survey monkey creates a page by default
    page1_id = "PAGE_FOR_CATEGORY1_#{question1.category.id}"
    page2_id = "PAGE_FOR_CATEGORY2_#{question2.category.id}"
    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey_monkey_id}/pages",
      responses: [
          {"data": [{"id": default_page}]},
          {"data": [{"id": default_page}]},
          {"data": [{"id": default_page}, {"id": page2_id}]},
          {"data": [{"id": page2_id}]},
          {"data": [{"id": page1_id}, {"id": page2_id}]}
      ]
    )

    survey_monkey_mock(
      method: :post,
      url: "surveys/#{survey_monkey_id}/pages",
      body: {"title": question1.category.name},
      responses: [{"id": page1_id}]
    )

    survey_monkey_mock(
      method: :post,
      url: "surveys/#{survey_monkey_id}/pages",
      body: {"title": question2.category.name},
      responses: [{"id": page2_id}]
    )

    survey_monkey_mock(
      method: :post,
      url: "surveys/#{survey_monkey_id}/pages/#{page1_id}/questions",
      body: question1.survey_monkey_structure,
      responses: [{"id": question1_id}]
    )

    survey_monkey_mock(
      method: :post,
      url: "surveys/#{survey_monkey_id}/pages/#{page2_id}/questions",
      body: question2.survey_monkey_structure,
      responses: [{"id": question2_id}]
    )

    survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey_monkey_id}/pages/#{default_page}"
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

    survey = Survey.find_by_name(survey_name)
    assert_equal "/admin/surveys/#{survey.id}", path

    assert_equal 2, survey.survey_questions.count
    survey.survey_questions.each do |sq|
      assert_not_empty sq.survey_monkey_id
      assert_not_empty sq.survey_monkey_page_id
    end
  end

  def test_show
    survey = surveys(:two)

    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [{'title': survey.name}]
    )

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
      responses: [{"title": new_survey_name}]
    )

    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/pages",
      responses: [{"data": [{"id": "PAGE"}]}]
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

  test "updating survey to add another question" do
    survey = surveys(:one)
    question = questions(:one)
    question_count = survey.questions.count

    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [{"title": survey.name}]
    )

    question_id = "ID_FOR_QUESTION_#{question.id}"
    page_id = "PAGE_FOR_CATEGORY_#{question.category.id}"
    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/pages",
      responses: [{"data": [
        {"id": page_id, "title": question.category.name}
      ]}]
    )

    survey_monkey_mock(
      method: :post,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{page_id}/questions",
      body: question.survey_monkey_structure
    )

    patch admin_survey_url(survey), headers: authorized_headers, params: {
      survey: { question_ids: [question.id] }
    }

    assert_equal question_count + 1, survey.reload.questions.count
  end

  test "updating survey to remove a question" do
    survey = surveys(:two)
    question = questions(:one)
    deleting_question = questions(:two)
    survey_question = survey.survey_questions.for(deleting_question).first
    question_count = survey.questions.count
    survey_question_count = SurveyQuestion.count

    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [{"title": survey.name}]
    )

    survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/pages",
      responses: [{"data": [{"id": survey_question.survey_monkey_page_id}]}]
    )

    survey_monkey_mock(
      method: :delete,
      url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_question.survey_monkey_page_id}/questions/#{survey_question.survey_monkey_id}"
    )

    patch admin_survey_url(survey), headers: authorized_headers, params: {
      survey: { question_ids: [question.id] }
    }

    assert_equal question_count - 1, survey.reload.questions.count
    assert_equal survey_question_count - 1, SurveyQuestion.count
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
