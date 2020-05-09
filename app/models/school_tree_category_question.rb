class SchoolTreeCategoryQuestion < ApplicationRecord

  belongs_to :survey
  belongs_to :school
  belongs_to :tree_category_question

  before_validation :assign_survey
  after_destroy :destroy_survey_monkey
  after_commit :create_survey_monkey, on: :create

  default_scope { joins(:survey, :tree_category_question) }

  # scope :for, -> (question) { where(question: question) }
  scope :on_page, -> (page_id) { where(survey_monkey_page_id: page_id) }

  def to_s
    "#{question.text} for #{school.name}"
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

  private
  def assign_survey
    survey = tree.surveys.where(school: school, kind: question.kind).first

    if survey.nil?
      survey = tree.surveys.create(
        school: school,
        name: "#{tree.name} #{question.kind.gsub(/_/, ' ').titleize}",
        kind: question.kind
      )
    end

    self.survey = survey
  end

  def create_survey_monkey
    return true unless id_previously_changed? # this shouldn't be necessary but this callback is sometimes called on update
    survey.create_survey_monkey_question(self)
  end

  def destroy_survey_monkey
    survey.remove_survey_monkey_question(self)
  end


end
