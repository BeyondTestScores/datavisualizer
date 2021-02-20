class SchoolTreeCategoryQuestion < ApplicationRecord

  belongs_to :survey
  belongs_to :school
  belongs_to :tree_category_question
  has_many :responses

  before_validation :assign_survey
  after_destroy :destroy_survey_monkey
  after_commit :create_survey_monkey, on: :create
  after_update :update_category_totals

  default_scope { joins(:survey, :tree_category_question) }

  scope :for_school, -> (school) { where(school: school) }
  scope :for_survey, -> (survey) { where(survey: survey) }
  scope :for_question, -> (question) { joins(:tree_category_question).merge(TreeCategoryQuestion.for_question(question)) }
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

  def tree_category
    tree_category_question.tree_category
  end

  def school_tree_category
    tree_category_question.tree_category.school_tree_category(school)
  end

  def category_path(include_self: false)
    tree_category_question.category_path(include_self)
  end

  def question
    tree_category_question.question
  end

  def sync_surveys
    survey.update_survey_monkey_question(self)
  end

  def responses_average
    return "" if responses_count == 0
    responses_sum.to_f / responses_count.to_f
  end

  def update_totals
    return if responses.empty?

    update(
      responses_sum: responses.sum(&:option),
      responses_count: responses.length
    )
  end

  def update_category_totals
    return unless school_tree_category.present? 
    school_tree_category.update_totals
  end

  private
  def assign_survey
    survey = tree.surveys.for_school(school).for_kind(question.kind).first

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
