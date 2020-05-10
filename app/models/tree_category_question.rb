class TreeCategoryQuestion < ApplicationRecord
  belongs_to :tree_category
  belongs_to :question
  has_many :school_tree_category_questions, dependent: :destroy

  accepts_nested_attributes_for :question

  default_scope { joins(:question, :tree_category) }

  scope :for, -> (question) { where(question: question) }

  after_create :create_school_tree_category_questions
  after_update_commit :sync_surveys

  def to_s
    question.text
  end

  def tree
    tree_category.tree
  end

  def category
    tree_category.category
  end

  def category_path(include_self: false)
    tree_category.path(include_self: include_self)
  end

  private
  def sync_surveys
    school_tree_category_questions.each do |stcq|
      stcq.sync_surveys
    end
  end

  def create_school_tree_category_questions
    School.all.each do |school|
      school_tree_category_questions.find_or_create_by(school: school)
    end
  end

end
