require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  def test_sets_slug_on_create
    category = Category.create(name: "Test")
    assert_equal "test", category.slug
  end

  def test_path
    path = [categories(:one), categories(:two)]
    assert_equal path.map(&:name), categories(:four).path.map(&:name)
  end

  def test_path__includes_self
    self_path = [categories(:one), categories(:two), categories(:four)]
    assert_equal self_path.map(&:name), categories(:four).path(include_self: true).map(&:name)
  end

  def test_all_questions
    category = categories(:three)
    questions = category.questions.to_a

    subcategory = category.child_categories.create(name: "subcategory")
    questions << subcategory.questions.create(text: "subcategory question")
    questions << subcategory.questions.create(text: "subcategory question2")

    subcategory2 = category.child_categories.create(name: "subcategory2")
    questions << subcategory.questions.create(text: "subcategory2 question")
    questions << subcategory.questions.create(text: "subcategory2 question2")

    subsubcatgory = subcategory.child_categories.create(name: "subsubcategory")
    questions << subsubcatgory.questions.create(text: "subsubcatgory question")
    questions << subsubcatgory.questions.create(text: "subsubcatgory question2")

    subsubcatgory2 = subcategory.child_categories.create(name: "subsubcategory2")
    questions << subsubcatgory.questions.create(text: "subsubcatgory2 question")
    questions << subsubcatgory.questions.create(text: "subsubcatgory2 question2")
  end

  def test_delete_also_deletes_questions


    category = categories(:two)
    question_count = Question.count
    category.destroy
    assert_equal question.count - 1, Question.count
  end

  def test_incomplete
    incomplete = Category.incomplete.to_a
    assert incomplete.include?(categories(:three))
    assert incomplete.include?(categories(:four))
    assert_not incomplete.include?(categories(:administrative_measure))

    categories(:three).questions.create(
      text: "Question?",
      option1: "Option 1",
      option2: "Option 2",
      option3: "Option 3",
      option4: "Option 4",
      option5: "Option 5"
    )
    assert_equal 1, categories(:three).questions.count

    incomplete = Category.incomplete.to_a
    assert_not incomplete.include?(categories(:three))
    assert incomplete.include?(categories(:four))

    categories(:four).child_categories.create(administrative_measure: true, name: 'An Administrative Measure')

    incomplete = Category.incomplete.to_a
    assert_not incomplete.include?(categories(:three))
    assert_not incomplete.include?(categories(:four))
  end

end
