require 'test_helper'

class SchoolTreeCategoryQuestionTest < ActiveSupport::TestCase

  test "Adding first school_tree_category_question of a kind to a tree creates a survey of that kind with that question" do
    requests = []

    tree_category = tree_categories(:four)
    tree_survey_for_community_count = tree_category.tree.surveys.for_community.count

    requests << survey_monkey_mock(
      method: :post,
      url: "surveys",
      body: {title: "2020-2021 For Community"}
    )

    question_for_community = Question.create(
      text: "Do you like this school?",
      option1: "Option 1",
      option2: "Option 2",
      option3: "Option 3",
      option4: "Option 4",
      option5: "Option 5",
      kind: Question.kinds[:for_community]
    )

    stc = tree_category.tree_category_questions.create(
      question: question_for_community
    )

    stcq = stc.school_tree_category_questions.create(
      school: schools(:one)
    )

    assert_equal tree_survey_for_community_count + 1, tree_category.tree.surveys.for_community.count
    assert tree_category.tree.surveys.for_community.last.school_tree_category_questions.include?(stcq)

    assert_requests requests
  end

end
