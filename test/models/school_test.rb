require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  test "creates school_tree_categories for all categories marked as admininistrative measures on create" do
    administrative_measure_count = Category.administrative_measure.count
    school_tree_category_count = SchoolTreeCategory.count

    School.create(name: "New School")

    assert_equal school_tree_category_count + administrative_measure_count, SchoolTreeCategory.count
  end
end
