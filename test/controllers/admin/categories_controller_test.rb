require 'test_helper'

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  def test_authentication
    # get the admin page
    get "/admin/categories/new"
    assert_equal 401, status

    # post the login and follow through to the home page
    get "/admin/categories/new", headers: {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }
    assert_equal "/admin/categories/new", path
  end

  def test_new_has_form
    get "/admin/categories/new", headers: {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }
    assert_select "form"
    assert_select "option", Category.count + 1
  end

  def test_create__only_requires_name
    category_count = Category.count
    post "/admin/categories", headers: {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }
    assert_equal category_count, Category.count

    post "/admin/categories", headers: {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }, params: {
      name: "New Category"
    }
    assert_equal category_count + 1, Category.count
  end

  def test_create__assigns_parent_category
    parent_category = Category.last
    child_category_count = parent_category.child_categories.count

    post "/admin/categories", headers: {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }, params: {
      name: "New Category",
      parent_category_id: parent_category.id
    }

    assert_equal child_category_count + 1, parent_category.child_categories.count
    assert_equal Category.find_by_name("New Category").parent_category, parent_category
  end
end
