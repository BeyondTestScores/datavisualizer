require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  def test_sets_slug_on_create
    category = Category.create(name: "Test")
    assert_equal "test", category.slug
  end
  
end
