class SchoolTreeCategoryQuestion < ApplicationRecord

  belongs_to :survey
  belongs_to :tree_category_question

  after_destroy :destroy_survey_monkey
  after_commit :create_survey_monkey, on: :create

  default_scope { joins(:survey, :tree_category_question) }

  # scope :for, -> (question) { where(question: question) }
  scope :on_page, -> (page_id) { where(survey_monkey_page_id: page_id) }

  def create_survey_monkey
    return true unless id_previously_changed? # this shouldn't be necessary but this callback is sometimes called on update
    survey.create_survey_monkey_question(self)
  end

  def destroy_survey_monkey
    survey.remove_survey_monkey_question(self)
  end

  def tree
    tree_category_question.tree
  end

  def category
    tree_category_question.category
  end

  def category_path(include_self: false)
    tree_category_question.category_path(include_self)
  end

  def question
    tree_category_question.question
  end

end
