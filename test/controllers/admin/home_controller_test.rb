require 'test_helper'

class Admin::HomeControllerTest < ActionDispatch::IntegrationTest
  def test_authentication
    # get the admin page
    get "/admin"
    assert_equal 401, status

    # post the login and follow through to the home page
    get "/admin", headers: {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }
    assert_equal "/admin", path
  end

  def test_index_links_to_create_new_category
    get "/admin", headers: {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }
    assert_select "a", "+ Create New Survey", :href => /admin\/surveys\/new/
    assert_select "a", "+ Create New Category", :href => /admin\/categories\/new/
    assert_select "a", "+ Create New Question", :href => /admin\/questions\/new/
  end
end
