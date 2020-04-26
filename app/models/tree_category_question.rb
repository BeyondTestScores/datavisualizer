class TreeCategoryQuestion < ApplicationRecord
  belongs_to :tree_category
  belongs_to :question
  has_many :school_tree_category_questions, dependent: :destroy

  accepts_nested_attributes_for :question

  default_scope { joins(:question, :tree_category) }

  scope :for, -> (question) { where(question: question) }

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

end
