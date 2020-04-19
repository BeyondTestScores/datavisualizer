require 'test_helper'

class Admin::HomeControllerTest < ActionDispatch::IntegrationTest
  def test_authentication
    # get the admin page
    get "/admin"
    assert_equal 401, status

    # post the login and follow through to the home page
    get "/admin", headers: authorized_headers
    assert_equal "/admin", path
  end

  def test_index_links_to_create_new_category
    get "/admin", headers: authorized_headers
    assert_select "a", "+ Create New School", :href => /admin\/schools\/new/
    assert_select "a", "+ Create New Category", :href => /admin\/categories\/new/
    assert_select "a", "+ Create New Question", :href => /admin\/questions\/new/
  end
end
