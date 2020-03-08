require 'test_helper'

class Admin::QuestionsControllerTest < ActionDispatch::IntegrationTest

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
    assert_select "checkbox", Question.count
  end

  def test_create__requirements
    survey_count = Survey.count
    post "/admin/questions", headers: authorized_headers
    assert_select "p", "Invalid Parameters"
    assert_equal survey_count, Survey.count

    post "/admin/surveys", headers: authorized_headers, params: {
      question: {
        name: ""
      }
    }
    assert_select "li", "Name can't be blank"
    assert_select "li", "Questions must exist"
    assert_equal survey_count, Survey.count

    survey = Survey.last
    post "/admin/surveys", headers: authorized_headers, params: {
      question: {
        name: "New Survey",
        question_ids: [Questions.first.id, Questions.last.id]
      }
    }
    assert_equal survey_count + 1, Survey.count
    assert_equal 302, status
    follow_redirect!

    survey = Survey.last
    assert_equal "/admin/survey/#{survey.id}", path
    assert_equal 2, survey.questions.count
  end

  def test_show
    survey = surveys(:two)
    get "/admin/surveys/#{survey.id}", headers: authorized_headers

    assert_select "h2", survey.name
    assert_select "p", survey.questions.first.text
  end

  # def test_index
  #   get "/admin/categories", headers: authorized_headers
  #   assert_select "h2", "All Categories"
  #   Category.all.each do |c|
  #     assert_select "a", c.name, href: admin_category_path(c)
  #   end
  # end
end
