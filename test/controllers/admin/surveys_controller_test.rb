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

  # def test_create__requirements
  #   requests = []
  #   survey_name = "New Survey For Test"
  #   survey_monkey_id = "SURVEY_MONKEY_ID"
  #
  #   stcq1 = school_tree_category_questions(:one)
  #   stcq1_id = "ID_FOR_QUESTION1_#{stcq1.id}"
  #
  #   stcq2 = school_tree_category_questions(:two)
  #   stcq2_id = "ID_FOR_QUESTION2_#{stcq2.id}"
  #
  #   default_page = "DEFAULT_PAGE" #survey monkey creates a page by default
  #   page1_id = "PAGE_FOR_CATEGORY1_#{stcq1.category.id}"
  #   page2_id = "PAGE_FOR_CATEGORY2_#{stcq2.category.id}"
  #
  #   requests << survey_monkey_mock(
  #     method: :post,
  #     url: "surveys",
  #     body: {"title": survey_name},
  #     responses: [{"title": survey_name, "id": survey_monkey_id}]
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :get,
  #     url: "surveys/#{survey_monkey_id}/details",
  #     responses: [
  #       details(survey: Survey.new(name: survey_name, survey_monkey_id: survey_monkey_id)),
  #       details(
  #         survey: Survey.new(name: survey_name, survey_monkey_id: survey_monkey_id),
  #         survey_questions: [
  #             SchoolTreeCategoryQuestion.new(
  #               tree_category_question: tree_category_questions(:one),
  #               survey_monkey_id: stcq1_id,
  #               survey_monkey_page_id: page1_id
  #             )
  #         ]
  #       )
  #     ],
  #     times: 2
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :get,
  #     url: "surveys/#{survey_monkey_id}/pages",
  #     responses: [
  #         {"data": [{"id": default_page}]},
  #         {"data": [{"id": default_page}, {"id": page2_id}]}
  #     ],
  #     times: 2
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :post,
  #     url: "surveys/#{survey_monkey_id}/pages",
  #     body: {"title": stcq1.category.name},
  #     responses: [{"id": page1_id}]
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :delete,
  #     url: "surveys/#{survey_monkey_id}/pages/#{DEFAULT_PAGE_ID}"
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :post,
  #     url: "surveys/#{survey_monkey_id}/pages",
  #     body: {"title": stcq2.category.name},
  #     responses: [{"id": page2_id}]
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :post,
  #     url: "surveys/#{survey_monkey_id}/pages/#{page1_id}/questions",
  #     body: stcq1.question.survey_monkey_structure,
  #     responses: [{"id": stcq1_id}]
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :post,
  #     url: "surveys/#{survey_monkey_id}/pages/#{page2_id}/questions",
  #     body: stcq2.question.survey_monkey_structure,
  #     responses: [{"id": stcq2_id}]
  #   )
  #
  #   survey_count = Survey.count
  #   post "/admin/surveys", headers: authorized_headers
  #   assert_select "p", "Invalid Parameters"
  #   assert_equal survey_count, Survey.count
  #
  #   post "/admin/surveys", headers: authorized_headers, params: {
  #     survey: {
  #       name: ""
  #     }
  #   }
  #   assert_select "li", "Name can't be blank"
  #   assert_equal survey_count, Survey.count
  #
  #   survey = Survey.last
  #   post "/admin/surveys", headers: authorized_headers, params: {
  #     survey: {
  #       name: survey_name,
  #       school_id: schools(:one).id,
  #       kind: :for_students,
  #       school_tree_category_question_ids: [SchoolTreeCategoryQuestion.first.id, SchoolTreeCategoryQuestion.last.id]
  #     }
  #   }
  #   assert_equal survey_count + 1, Survey.count
  #   assert_equal 302, status
  #   follow_redirect!
  #
  #   survey = Survey.find_by_name(survey_name)
  #   assert_equal "/admin/surveys/#{survey.id}", path
  #
  #   assert_equal 2, survey.survey_questions.count
  #   survey.survey_questions.each do |sq|
  #     assert_not_empty sq.survey_monkey_id
  #     assert_not_empty sq.survey_monkey_page_id
  #   end
  #
  #   assert_requests requests
  # end

  def test_show
    requests = []
    survey = surveys(:one_teachers)

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [{'title': survey.name}]
    )

    get "/admin/surveys/#{survey.id}", headers: authorized_headers

    assert_select "h2", survey.name
    assert_select "a", survey.school_tree_category_questions.first.question.text

    assert_requests requests
  end

  test "should get edit" do
    survey = surveys(:one_teachers)
    get edit_admin_survey_url(survey), headers: authorized_headers
    assert_response :success
  end

  test "should update survey" do
    requests = []

    survey = surveys(:one_teachers)
    new_survey_name = "New Survey Name"

    requests << survey_monkey_mock(
      method: :get,
      url: "surveys/#{survey.survey_monkey_id}/details",
      responses: [details(survey: survey)]
    )

    requests << survey_monkey_mock(
      method: :patch,
      url: "surveys/#{survey.survey_monkey_id}",
      body: {"title": "New Survey Name"}
    )

    patch admin_survey_url(survey), headers: authorized_headers, params: {
      survey: { name: new_survey_name, survey_monkey_id: survey.survey_monkey_id }
    }
    assert_redirected_to admin_survey_url(survey)

    assert_requests requests
  end

  # test "updating survey to add another question" do
  #   requests = []
  #
  #   survey = surveys(:one)
  #   question = questions(:one)
  #   question_count = survey.questions.count
  #
  #   question_id = "ID_FOR_QUESTION_#{question.id}"
  #   page_id = "PAGE_FOR_CATEGORY_#{question.category.id}"
  #   requests << survey_monkey_mock(
  #     method: :get,
  #     url: "surveys/#{survey.survey_monkey_id}/details",
  #     responses: [
  #       details(survey: survey),
  #       details(
  #         survey: survey,
  #         survey_questions: [
  #           SurveyQuestion.new(
  #             question: question,
  #             survey_monkey_id: question_id,
  #             survey_monkey_page_id: page_id
  #           )
  #         ]
  #       )
  #     ],
  #     times: 2
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :get,
  #     url: "surveys/#{survey.survey_monkey_id}/pages",
  #     responses: [{"data": [{"id": DEFAULT_PAGE_ID}]}]
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :post,
  #     url: "surveys/#{survey.survey_monkey_id}/pages",
  #     body: {"title": question.category.name},
  #     responses: [{"id": page_id}]
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :post,
  #     url: "surveys/#{survey.survey_monkey_id}/pages/#{page_id}/questions",
  #     body: question.survey_monkey_structure
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :delete,
  #     url: "surveys/#{survey.survey_monkey_id}/pages/#{DEFAULT_PAGE_ID}"
  #   )
  #
  #
  #   patch admin_survey_url(survey), headers: authorized_headers, params: {
  #     survey: { question_ids: [question.id] }
  #   }
  #
  #   assert_equal question_count + 1, survey.reload.questions.count
  #
  #   assert_requests requests
  # end

  # test "updating survey to remove a question" do
  #   requests = []
  #
  #   survey = surveys(:one_teachers)
  #   question = questions(:one)
  #   deleting_question = questions(:two)
  #   survey_question = survey.survey_questions.for_question(deleting_question).first
  #   question_count = survey.questions.count
  #   survey_question_count = SurveyQuestion.count
  #
  #   requests << survey_monkey_mock(
  #     method: :delete,
  #     url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_question.survey_monkey_page_id}/questions/#{survey_question.survey_monkey_id}"
  #   )
  #
  #   remaining_survey_questions = survey_questions.select { |sq| sq.question_id != deleting_question.id }
  #   requests << survey_monkey_mock(
  #     method: :get,
  #     url: "surveys/#{survey.survey_monkey_id}/details",
  #     responses: [
  #       details(
  #         survey: survey,
  #         survey_questions: remaining_survey_questions,
  #         pages: [{"id": survey_question.survey_monkey_page_id}]
  #       ),
  #       details(survey: survey, survey_questions: remaining_survey_questions)
  #     ],
  #     times: 2
  #   )
  #
  #   requests << survey_monkey_mock(
  #     method: :delete,
  #     url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_question.survey_monkey_page_id}"
  #   )
  #
  #   patch admin_survey_url(survey), headers: authorized_headers, params: {
  #     survey: { question_ids: [question.id] }
  #   }
  #
  #   assert_equal question_count - 1, survey.reload.questions.count
  #   assert_equal survey_question_count - 1, SurveyQuestion.count
  #
  #   assert_requests requests
  # end

  # test "should destroy survey" do
  #   survey = surveys(:two)
  #   assert_difference('Survey.count', -1) do
  #     delete admin_survey_url(survey), headers: authorized_headers
  #   end
  #
  #   assert_redirected_to surveys_url
  # end

end
