require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  test "creates school_categories for all categories marked as admininistrative measures on create" do
    administrative_measure_count = Category.administrative_measure.count
    school_category_count = SchoolCategory.count

    School.create(name: "New School")

    assert_equal school_category_count + administrative_measure_count, SchoolCategory.count
  end
end
