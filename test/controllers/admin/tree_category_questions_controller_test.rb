require 'test_helper'

class Admin::TreeCategoryQuestionsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @tree_category = tree_categories(:one)
  end

  def root_path
    "/admin/trees/#{@tree_category.tree.slug}/categories/#{@tree_category.category.slug}"
  end

  def authorized_headers
    return {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }
  end

  def test_new_has_form
    get "#{root_path}/questions/new", headers: authorized_headers
    assert_select "select[name='tree_category_question[tree_category_id]']" do
      assert_select "option", Category.count + 1
      assert_select "option[value='#{@tree_category.id}'][selected]", {count: 1}
    end
    assert_select "label", "Who is this question for?"
    assert_select "select[name='tree_category_question[question_attributes][kind]']" do
      assert_select "option", Question.kinds.count + 1
    end
  end

  def test_create__requirements
    $survey_monkey_disabled = true

    question_count = Question.count
    post "#{root_path}/questions", headers: authorized_headers
    assert_select "p", "Invalid Parameters"
    assert_equal question_count, Question.count

    post "#{root_path}/questions", headers: authorized_headers, params: {
      tree_category_question: {
        question_attributes: {
          text: ""
        }
      }
    }
    assert_select "li", "Question text can't be blank"
    assert_select "li", "Question option1 can't be blank"
    assert_equal question_count, Question.count

    category = Category.last
    post "#{root_path}/questions", headers: authorized_headers, params: {
      tree_category_question: {
        question_attributes: {
          text: "New Question Text",
          option1: "Option 1",
          option2: "Option 2",
          option3: "Option 3",
          option4: "Option 4",
          option5: "Option 5",
          kind: 'for_students'
        }
      }
    }
    assert_equal question_count + 1, Question.count
    assert_equal 302, status
    follow_redirect!

    tree_category_question = TreeCategoryQuestion.last
    assert_equal "#{root_path}/questions/#{tree_category_question.question.id}", path
    assert_equal @tree_category, tree_category_question.tree_category

    $survey_monkey_disabled = false
  end

  def test_show
    tree_category_question = @tree_category.tree_category_questions.first
    get "#{root_path}/questions/#{tree_category_question.question.id}", headers: authorized_headers

    assert_select "h2", tree_category_question.question.text
    assert_select "p", tree_category_question.question.option1
    assert_select "a", @tree_category.name, :href => /categories\/#{@tree_category.category.slug}/
  end

  def test_edit
    tree_category_question = @tree_category.tree_category_questions.first
    get "#{root_path}/questions/#{tree_category_question.question.id}/edit", headers: authorized_headers

    assert_select "form"
    assert_select "select[name='tree_category_question[tree_category_id]']" do
      assert_select "option", Category.count + 1
      assert_select "option[value='#{@tree_category.id}'][selected]"
    end
  end

  def test_update
    new_question_text = "New Question Text"
    tree_category_question = tree_category_questions(:two)
    question = tree_category_question.question
    original_text = question.text

    question.text = new_question_text
    tree_category_question.school_tree_category_questions.each do |stcq|
      survey_monkey_id = stcq.survey.survey_monkey_id
      page_id = stcq.survey_monkey_page_id
      survey_monkey_question_id = stcq.survey_monkey_id
      survey_monkey_mock(
        method: :patch,
        url: "surveys/#{survey_monkey_id}/pages/#{page_id}/questions/#{survey_monkey_question_id}",
        body: stcq.question.survey_monkey_structure(1)
      )

      survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey_monkey_id}/details",
        responses: [{"title": stcq.survey.name}]
      )

      survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey_monkey_id}/pages",
        responses: [{"data": [{"id": page_id}]}]
      )
    end
    question.text = original_text

    patch "#{root_path}/questions/#{question.id}", headers: authorized_headers, params: {
      tree_category_question: {
        question_attributes: {
          id: question.id,
          text: new_question_text
        }
      }
    }

    assert_equal new_question_text, question.reload.text
  end

  # def test_update__updates_category
  #   requests = []
  #
  #   question = questions(:two)
  #   old_question_text = question.text
  #   new_question_text = "New Question Text"
  #   old_category = question.category
  #   new_category = categories(:three)
  #   question_count = new_category.questions.count
  #
  #   assert question.category != new_category
  #
  #   question.update_column("text", new_question_text)
  #   question.update_column("category_id", new_category.id)
  #   question.survey_questions.each do |survey_question|
  #     survey = survey_question.survey
  #     survey_monkey_id = survey.survey_monkey_id
  #     page_id = survey_question.survey_monkey_page_id
  #     survey_monkey_question_id = survey_question.survey_monkey_id
  #
  #     requests << survey_monkey_mock(
  #       method: :delete,
  #       url: "surveys/#{survey_monkey_id}/pages/#{page_id}/questions/#{survey_monkey_question_id}"
  #     )
  #
  #     requests << survey_monkey_mock(
  #       method: :get,
  #       url: "surveys/#{survey_monkey_id}/pages",
  #       responses: [{"data": details(survey: survey)["pages"]}]
  #     )
  #
  #     requests << survey_monkey_mock(
  #       method: :post,
  #       url: "surveys/#{survey_monkey_id}/pages/#{page_id}/questions",
  #       body: survey_question.question.survey_monkey_structure(1)
  #     )
  #
  #     requests << survey_monkey_mock(
  #       method: :get,
  #       url: "surveys/#{survey_monkey_id}/details",
  #       responses: [details(survey: survey)]
  #     )
  #
  #   end
  #   question.update_column("text", old_question_text)
  #   question.update_column("category_id", old_category.id)
  #
  #   patch "/admin/questions/#{question.id}", headers: authorized_headers, params: {
  #     question: {
  #       text: new_question_text,
  #       category_id: new_category.id
  #     }
  #   }
  #
  #   assert_equal Question.find_by_text(new_question_text).category, new_category
  #   assert_equal question_count + 1, new_category.questions.count
  #
  #   assert_requests requests
  # end

end
