require 'test_helper'

class SchoolCategoryTest < ActiveSupport::TestCase

  test "sets the date on create" do
    sc = SchoolCategory.create(school: schools(:one), category: categories(:four))
    assert_equal Time.new.year.to_s, sc.year
  end

end
