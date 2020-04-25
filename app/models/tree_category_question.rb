class TreeCategoryQuestion < ApplicationRecord

  belongs_to :tree_category
  belongs_to :question
  has_many :school_tree_category_questions, dependent: :destroy

end
