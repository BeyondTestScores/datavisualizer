require 'test_helper'

class TreeCategoryTest < ActiveSupport::TestCase

  def test_path
    path = [tree_categories(:one), tree_categories(:two)]
    assert_equal path.map(&:name), tree_categories(:four).path.map(&:name)
  end

  def test_path__includes_self
    self_path = [tree_categories(:one), tree_categories(:two), tree_categories(:four)]
    assert_equal self_path.map(&:name), tree_categories(:four).path(include_self: true).map(&:name)
  end

  def test_all_tree_category_questions
    tree_category = tree_categories(:three)
    tree_category_questions = tree_category.tree_category_questions.to_a

    sub_tree_category = tree_category.child_tree_category_categories.create(category_attributes: {name: "subcategory"})
    questions << sub_tree_category.tree_category_questions.create(text: "sub_tree_category question")
    questions << sub_tree_category.tree_category_questions.create(text: "sub_tree_category question2")

    sub_tree_category2 = tree_category.child_categories.create(category_attributes: {name: "sub_tree_category2"})
    questions << subcategory.tree_category_questions.create(text: "sub_tree_category2 question")
    questions << subcategory.tree_category_questions.create(text: "sub_tree_category2 question2")

    sub_sub_tree_category = sub_tree_category.child_categories.create(category_attributes: {name: "sub_sub_tree_category"})
    questions << sub_sub_tree_category.tree_category_questions.create(text: "sub_sub_tree_category question")
    questions << sub_sub_tree_category.tree_category_questions.create(text: "sub_sub_tree_category question2")

    sub_sub_tree_category_2 = sub_tree_category2.child_categories.create(category_attributes: {name: "sub_sub_tree_category_2"})
    questions << sub_sub_tree_category_2.tree_category_questions.create(text: "sub_sub_tree_category_2 question")
    questions << sub_sub_tree_category_2.tree_category_questions.create(text: "sub_sub_tree_category_2 question2")

    questions.each do |question|
      assert tree_category.all_tree_category_questions.include?(question)
    end
  end

  def test_delete_also_deletes_questions
    requests = []

    tree_category = tree_categories(:two)
    tree_category_question_count = TreeCategoryQuestion.count

    all_tree_category_questions = tree_category.all_tree_category_questions
    all_school_tree_category_questions = all_tree_category_questions.map(&:school_tree_category_questions).flatten.uniq
    deleted_stcqs = []
    all_school_tree_category_questions.each do |stcq|
      deleted_stcqs << stcq
      survey = stcq.survey

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}/questions/#{stcq.survey_monkey_id}"
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(
            survey: survey,
            survey_questions: survey.survey_questions - deleted_stcqs,
            pages: [{"id": stcq.survey_monkey_page_id, "title": category.name}]
          )
        ]
      )

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}"
      )
    end

    tree_category.destroy
    assert_equal tree_category_question_count - 1, SchoolTreeCategoryQuestion.count

    assert_requests requests
  end

  def test_incomplete
    incomplete = TreeCategory.incomplete.to_a
    assert incomplete.include?(tree_categories(:three))
    assert incomplete.include?(tree_categories(:four))
    assert_not incomplete.include?(tree_categories(:administrative_measure))

    tree_categories(:three).tree_category_questions.create(
      question_attributes: {
        text: "Question?",
        option1: "Option 1",
        option2: "Option 2",
        option3: "Option 3",
        option4: "Option 4",
        option5: "Option 5"
      }
    )
    assert_equal 1, tree_categories(:three).tree_category_questions.count

    incomplete = TreeCategory.incomplete.to_a
    assert_not incomplete.include?(tree_categories(:three))
    assert incomplete.include?(tree_categories(:four))

    tree_categories(:four).child_tree_categories.create(
      category_attributes: {
        administrative_measure: true,
        name: 'An Administrative Measure'
      }
    )
    assert_equal 1, tree_categories(:four).child_tree_categories.administrative_measure.count

    incomplete = TreeCategory.incomplete.to_a
    assert_not incomplete.include?(tree_categories(:three))
    assert_not incomplete.include?(tree_categories(:four))
  end

end
