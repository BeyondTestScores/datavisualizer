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

  def test_all_tree_category_questions_and_all_school_tree_category_questions
    $survey_monkey_disabled = true
    
    tree_category = tree_categories(:three)
    tree_category_questions = tree_category.tree_category_questions.to_a

    sub_tree_category = tree_category.child_tree_categories.create(category_attributes: {name: "subcategory"})
    tree_category_questions << sub_tree_category.tree_category_questions.create(question_attributes("sub_tree_category question"))
    tree_category_questions << sub_tree_category.tree_category_questions.create(question_attributes("sub_tree_category question2"))

    sub_tree_category2 = tree_category.child_tree_categories.create(category_attributes: {name: "sub_tree_category2"})
    tree_category_questions << sub_tree_category.tree_category_questions.create(question_attributes("sub_tree_category2 question"))
    tree_category_questions << sub_tree_category.tree_category_questions.create(question_attributes("sub_tree_category2 question2"))

    sub_sub_tree_category = sub_tree_category.child_tree_categories.create(category_attributes: {name: "sub_sub_tree_category"})
    tree_category_questions << sub_sub_tree_category.tree_category_questions.create(question_attributes("sub_sub_tree_category question"))
    tree_category_questions << sub_sub_tree_category.tree_category_questions.create(question_attributes("sub_sub_tree_category question2"))

    sub_sub_tree_category_2 = sub_tree_category2.child_tree_categories.create(category_attributes: {name: "sub_sub_tree_category_2"})
    tree_category_questions << sub_sub_tree_category_2.tree_category_questions.create(question_attributes("sub_sub_tree_category_2 question"))
    tree_category_questions << sub_sub_tree_category_2.tree_category_questions.create(question_attributes("sub_sub_tree_category_2 question2"))

    tree_category_questions.each do |tcq|
      assert tree_category.all_tree_category_questions.include?(tcq), "#{tcq.question.text} not found"

      School.all.each do |school|
        stcq = tcq.school_tree_category_questions.for_school(school).first
        assert stcq.present?, "#{tcq.question.text} for #{school.name} does not exist"
        assert tree_category.all_school_tree_category_questions.include?(stcq), "#{stcq.question.text} for #{school.name} not found"
      end
    end

    $survey_monkey_disabled = false
  end

  def test_delete_also_deletes_questions
    requests = []

    tree_category = tree_categories(:one)
    tree_category_question_count = TreeCategoryQuestion.count
    school_tree_category_question_count = SchoolTreeCategoryQuestion.count

    all_school_tree_category_questions = tree_category.all_school_tree_category_questions
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
            survey_questions: survey.school_tree_category_questions - deleted_stcqs,
            pages: [{"id": stcq.survey_monkey_page_id, "title": tree_category.category.name}]
          )
        ]
      )

      requests << survey_monkey_mock(
        method: :delete,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{stcq.survey_monkey_page_id}"
      )
    end

    assert deleted_stcqs.length > 0

    tree_category.destroy
    assert_equal tree_category_question_count - 2, TreeCategoryQuestion.count
    assert_equal school_tree_category_question_count - deleted_stcqs.length, SchoolTreeCategoryQuestion.count

    assert_requests requests
  end

  def test_incomplete
    requests = []

    incomplete = TreeCategory.incomplete.to_a
    assert incomplete.include?(tree_categories(:three))
    assert incomplete.include?(tree_categories(:four))
    assert_not incomplete.include?(tree_categories(:administrative_measure))

    tcq = tree_categories(:three).tree_category_questions.new(
      question_attributes: {
        text: "Question?",
        option1: "Option 1",
        option2: "Option 2",
        option3: "Option 3",
        option4: "Option 4",
        option5: "Option 5",
        kind: Question.kinds[:for_students]
      }
    )

    [surveys(:one_students), surveys(:two_students)].each do |survey|
      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/pages",
        responses: [{"data": []}]
      )

      survey_monkey_page_id = "SURVEY_MONKEY_PAGE_ID"
      requests << survey_monkey_mock(
        method: :post,
        url: "surveys/#{survey.survey_monkey_id}/pages",
        body: {"title": tree_categories(:three).category.name},
        responses: [
          {"id": survey_monkey_page_id}
        ]
      )

      survey_monkey_question_id = "SURVEY_MONKEY_QUESTION_ID"
      requests << survey_monkey_mock(
        method: :post,
        url: "surveys/#{survey.survey_monkey_id}/pages/#{survey_monkey_page_id}/questions",
        body: tcq.question.survey_monkey_structure,
        responses: [{"id": survey_monkey_question_id}]
      )

      requests << survey_monkey_mock(
        method: :get,
        url: "surveys/#{survey.survey_monkey_id}/details",
        responses: [
          details(survey: survey, survey_questions: survey.school_tree_category_questions + [
            tcq.school_tree_category_questions.new(
              survey: survey,
              school: survey.school,
              survey_monkey_id: survey_monkey_question_id,
              survey_monkey_page_id: survey_monkey_page_id)
          ])
        ]
      )
    end

    tcq.save
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

    assert_requests requests
  end

  def question_attributes(text)
    {
      question_attributes: {
        text: text,
        option1: "Option 1",
        option2: "Option 2",
        option3: "Option 3",
        option4: "Option 4",
        option5: "Option 5",
        kind: Question.kinds[:for_students]
      }
    }
  end

end
