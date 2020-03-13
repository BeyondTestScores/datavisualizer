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
    get "/admin/questions/new"
    assert_equal 401, status

    # post the login and follow through to the home page
    get "/admin/questions/new", headers: authorized_headers
    assert_equal "/admin/questions/new", path
  end

  def test_new_has_form
    get "/admin/questions/new", headers: authorized_headers
    assert_select "select" do
      assert_select "option", Category.count + 1
      assert_select "option[selected]", {count: 0}
    end
  end

  def test_new_assigns_category_id_when_passed_in
    category = categories(:two)
    get "/admin/questions/new?category_id=#{category.id}", headers: authorized_headers
    assert_select "select" do
      assert_select "option", Category.count + 1
      assert_select "option[value='#{category.id}'][selected]", {count: 1}
    end
  end

  def test_create__requirements
    question_count = Question.count
    post "/admin/questions", headers: authorized_headers
    assert_select "p", "Invalid Parameters"
    assert_equal question_count, Question.count

    post "/admin/questions", headers: authorized_headers, params: {
      question: {
        text: ""
      }
    }
    assert_select "li", "Text can't be blank"
    assert_select "li", "Category must exist"
    assert_select "li", "Option1 can't be blank"
    assert_equal question_count, Question.count

    category = Category.last
    post "/admin/questions", headers: authorized_headers, params: {
      question: {
        text: "New Question Text",
        option1: "Option 1",
        option2: "Option 2",
        option3: "Option 3",
        option4: "Option 4",
        option5: "Option 5",
        category_id: category.id
      }
    }
    assert_equal question_count + 1, Question.count
    assert_equal 302, status
    follow_redirect!

    question = Question.last
    assert_equal "/admin/questions/#{question.id}", path
    assert_equal category, question.category
  end

  def test_show
    question = questions(:two)
    get "/admin/questions/#{question.id}", headers: authorized_headers

    assert_select "h2", question.text
    assert_select "p", question.option1
    assert_select "a", categories(:two).name, :href => /categories\/#{categories(:two).slug}/
  end

  def test_edit
    question = questions(:two)
    get "/admin/questions/#{question.id}/edit", headers: authorized_headers

    assert_select "form"
    assert_select "select" do
      assert_select "option", Category.count + 1
      assert_select "option[value='#{question.category.id}'][selected]"
    end
  end

  def test_update__updates_category
    question = questions(:two)
    new_category = categories(:three)
    question_count = new_category.questions.count

    assert question.category != new_category

    patch "/admin/questions/#{question.id}", headers: authorized_headers, params: {
      question: {
        text: "New Question Text",
        category_id: new_category.id
      }
    }

    assert_equal Question.find_by_text("New Question Text").category, new_category
    assert_equal question_count + 1, new_category.questions.count
  end

  # Why is this crashing the tests?
  # def test_destroy__doesnt_destroy_category
  #   category_count = Category.count
  #   category = categories(:two)
  #   assert_equal 1, category.questions.count
  #   question_count = Question.count
  #
  #   delete admin_question_url(question), headers: authorized_headers
  #   # assert_redirected_to admin_root_path
  #   # assert_select h3, "Question was successfully destroyed."
  #
  #   assert_equal category_count, Category.count
  #   assert_equal question_count - 1, category.questions.count
  # end


  # def test_index
  #   get "/admin/categories", headers: authorized_headers
  #   assert_select "h2", "All Categories"
  #   Category.all.each do |c|
  #     assert_select "a", c.name, href: admin_category_path(c)
  #   end
  # end
end
