require 'test_helper'

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @tree = trees(:one)
  end

  def test_new_has_form
    get "/admin/trees/#{@tree}/categories/new", headers: authorized_headers
    assert_select "select" do
      assert_select "option", Category.count + 1
      assert_select "option[selected]", {count: 0}
    end
  end

  def test_new_assigns_parent_tree_category_id_when_passed_in
    parent_category = categories(:two)
    get "/admin/trees/#{@tree}/categories/new?parent_tree_category_id=#{parent_category.id}", headers: authorized_headers
    assert_select "select" do
      assert_select "option", Category.count + 1
      assert_select "option[value='#{parent_category.id}'][selected]", {count: 1}
    end
  end

  def test_create__only_requires_name_for_category
    category_count = Category.count
    post "/admin/trees/#{@tree}/categories", headers: authorized_headers
    assert_select "p", "Invalid Parameters"
    assert_equal category_count, Category.count

    post "/admin/trees/#{@tree}/categories", headers: authorized_headers, params: {
      tree_category: {
        category_attributes: {
          name: ""
        }
      }
    }
    assert_select "li", "Category name can't be blank"
    assert_equal category_count, Category.count

    post "/admin/trees/#{@tree}/categories", headers: authorized_headers, params: {
      tree_category: {
        category_attributes: {
          name: "New Category"
        }
      }
    }
    assert_equal category_count + 1, Category.count
    assert_equal 302, status
    follow_redirect!
    assert_equal "/admin/trees/#{@tree}/categories/new-category", path
  end

  def test_create__assigns_parent_tree_category
    parent_tree_category = TreeCategory.last
    child_tree_category_count = parent_tree_category.child_tree_categories.count
    assert_not parent_tree_category.child_tree_categories.map(&:name).include?("New Category")

    post "/admin/trees/#{@tree}/categories", headers: authorized_headers, params: {
      tree_category: {
        parent_tree_category_id: parent_tree_category.id,
        category_attributes: {
          name: "New Category"
        },
      }
    }

    assert_equal child_tree_category_count + 1, parent_tree_category.reload.child_tree_categories.count
    assert parent_tree_category.child_tree_categories.map(&:name).include?("New Category")
  end

  def test_show
    category = categories(:two)
    get "/admin/trees/#{@tree}/categories/#{category.slug}", headers: authorized_headers

    assert_select "h2", category.name
    assert_select "a", categories(:one).name, :href => /categories\/#{categories(:one).slug}/
  end

  def test_show__with_no_parent_category
    category = categories(:one)
    get "/admin/trees/#{@tree}/categories/#{category.slug}", headers: authorized_headers

    assert_select "h2", category.name
    assert_select "p", {count: 0, text: /Parent/}
  end

  def test_edit
    tree_category = tree_categories(:two)
    get "/admin/trees/#{@tree}/categories/#{tree_category.category.slug}/edit", headers: authorized_headers

    assert_select "form"
    assert_select "select" do
      assert_select "option", Category.count + 1
      assert_select "option[value='#{tree_category.parent_tree_category.id}'][selected]"
    end
  end

  def test_update__updates_parent_category
    requests = []

    tree_category = tree_categories(:two)
    new_parent_tree_category = tree_categories(:three)
    child_tree_category_count = new_parent_tree_category.child_tree_categories.count

    old_category_name = tree_category.name
    new_category_name = "Renamed Category"

    assert tree_category.parent_tree_category != new_parent_tree_category

    tree_category.category.update_column('name', new_category_name)
    tree_category.tree_category_questions.each do |tcq|
      tcq.school_tree_category_questions.each do |stcq|
        survey = stcq.survey
        requests << survey_monkey_mock(
          method: :patch,
          url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}",
          body: {title: new_category_name}
        )

        requests << survey_monkey_mock(
          method: :get,
          url: "surveys/#{survey.survey_monkey_id}/details",
          responses: [details(survey: survey)]
        )
      end
    end
    tree_category.category.update_column('name', old_category_name)

    patch "/admin/trees/#{@tree}/categories/#{tree_category.category.slug}", headers: authorized_headers, params: {
      tree_category: {
        parent_tree_category_id: new_parent_tree_category.id,
        category_attributes: {name: new_category_name}
      }
    }

    assert_equal child_tree_category_count + 1, new_parent_tree_category.child_tree_categories.count
    updated_category = Category.find_by_name(new_category_name)
    assert_equal new_parent_tree_category, updated_category.tree_categories.first.parent_tree_category
    # assert_equal "renamed-category", updated_category.slug

    assert_requests requests
  end

  def test_destroy__also_destroys_questions
    requests = []

    tree_category_count = TreeCategory.count
    tree_category = tree_categories(:two)
    assert_equal 1, tree_category.tree_category_questions.count
    tree_category_question_count = TreeCategoryQuestion.count

    tree_category.tree_category_questions.each do |tcq|
      tcq.school_tree_category_questions.each do |stcq|
        survey = stcq.survey

        requests << survey_monkey_mock(
          method: :delete,
          url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}/questions/#{stcq.survey_monkey_id}"
        )

        requests << survey_monkey_mock(
          method: :get,
          url: "surveys/#{survey.survey_monkey_id}/details",
          responses: [details(
            survey: survey,
            survey_questions: [],
            pages: [{"id": stcq.survey_monkey_page_id}]
          )]
        )

        requests << survey_monkey_mock(
          method: :delete,
          url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}"
        )
      end
    end

    delete admin_tree_category_url(tree_category.tree, tree_category.category), headers: authorized_headers
    assert_redirected_to admin_root_path

    assert_equal tree_category_count - 4, TreeCategory.count # category and it's child categories
    assert_equal tree_category_question_count - 1, TreeCategoryQuestion.count

    assert_requests requests
  end

end
