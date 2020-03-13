require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  def test_sets_slug_on_create
    category = Category.create(name: "Test")
    assert_equal "test", category.slug
  end

  # Why is this crashing the tests?
  # def test_delete_also_deletes_questions
  #   category = categories(:two)
  #   question_count = Question.count
  #   category.destroy
  #   assert_equal question.count - 1, Question.count
  # end

end
