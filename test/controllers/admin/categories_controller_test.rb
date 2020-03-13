require 'test_helper'

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest

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
    get "/admin/categories/new"
    assert_equal 401, status

    # post the login and follow through to the home page
    get "/admin/categories/new", headers: authorized_headers
    assert_equal "/admin/categories/new", path
  end

  def test_new_has_form
    get "/admin/categories/new", headers: authorized_headers
    assert_select "select" do
      assert_select "option", Category.count + 1
      assert_select "option[selected]", {count: 0}
    end
  end

  def test_new_assigns_parent_category_id_when_passed_in
    parent_category = categories(:two)
    get "/admin/categories/new?parent_category_id=#{parent_category.id}", headers: authorized_headers
    assert_select "select" do
      assert_select "option", Category.count + 1
      assert_select "option[value='#{parent_category.id}'][selected]", {count: 1}
    end
  end

  def test_create__only_requires_name
    category_count = Category.count
    post "/admin/categories", headers: authorized_headers
    assert_select "p", "Invalid Parameters"
    assert_equal category_count, Category.count

    post "/admin/categories", headers: authorized_headers, params: {
      category: {
        name: ""
      }
    }
    assert_select "li", "Name can't be blank"
    assert_equal category_count, Category.count

    post "/admin/categories", headers: authorized_headers, params: {
      category: {
        name: "New Category"
      }
    }
    assert_equal category_count + 1, Category.count
    assert_equal 302, status
    follow_redirect!
    assert_equal "/admin/categories/new-category", path
  end

  def test_create__assigns_parent_category
    parent_category = Category.last
    child_category_count = parent_category.child_categories.count

    post "/admin/categories", headers: authorized_headers, params: {
      category: {
        name: "New Category",
        parent_category_id: parent_category.id
      }
    }

    assert_equal child_category_count + 1, parent_category.child_categories.count
    assert_equal Category.find_by_name("New Category").parent_category, parent_category
  end

  def test_show
    category = categories(:two)
    get "/admin/categories/#{category.slug}", headers: authorized_headers

    assert_select "h2", category.name
    assert_select "a", categories(:one).name, :href => /categories\/#{categories(:one).slug}/
  end

  def test_show__with_no_parent_category
    category = categories(:one)
    get "/admin/categories/#{category.slug}", headers: authorized_headers

    assert_select "h2", category.name
    assert_select "p", {count: 0, text: /Parent/}
  end

  def test_index
    get "/admin/categories", headers: authorized_headers
    assert_select "h2", "All Categories"
    Category.all.each do |c|
      assert_select "a", c.name, href: admin_category_path(c)
    end
  end

  def test_edit
    category = categories(:two)
    get "/admin/categories/#{category.slug}/edit", headers: authorized_headers

    assert_select "form"
    assert_select "select" do
      assert_select "option", Category.count + 1
      assert_select "option[value='#{category.parent_category.id}'][selected]"
    end
  end

  def test_update__updates_parent_category
    category = categories(:two)
    new_parent_category = categories(:three)
    child_category_count = new_parent_category.child_categories.count

    assert category.parent_category != new_parent_category

    patch "/admin/categories/#{category.slug}", headers: authorized_headers, params: {
      category: {
        name: "Renamed Category",
        parent_category_id: new_parent_category.id
      }
    }

    assert_equal child_category_count + 1, new_parent_category.child_categories.count
    updated_category = Category.find_by_name("Renamed Category")
    assert_equal new_parent_category, updated_category.parent_category
    # assert_equal "renamed-category", updated_category.slug
  end

  # Why is this crashing the tests?
  # def test_destroy__also_destroys_questions
  #   category_count = Category.count
  #   category = categories(:two)
  #   assert_equal 1, category.questions.count
  #   question_count = Question.count
  #
  #   delete admin_category_url(category), headers: authorized_headers
  #   # assert_redirected_to admin_root_path
  #   # assert_select h3, "Category was successfully destroyed."
  #
  #   assert_equal category_count - 1, Category.count
  #   assert_equal question_count - 1, Question.count
  # end
end
