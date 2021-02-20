class School < ApplicationRecord

  extend FriendlyId
  friendly_id :name, use: :slugged
  
  has_many :school_tree_categories, dependent: :destroy
  has_many :school_tree_category_questions, dependent: :destroy

  has_many :surveys, dependent: :destroy

  after_create :create_for_trees

  def to_s
    name
  end

  def create_for_trees
    TreeCategory.includes(:school_tree_categories, tree_category_questions: :school_tree_category_questions).each do |tc|
      unless school_tree_categories.find { |stc| stc.tree_category == tc }
        school_tree_categories.create(tree_category: tc)
      end

      tc.tree_category_questions.each do |tcq|
        next if school_tree_category_questions.find { |stcq| stcq.tree_category_question == tcq }
        school_tree_category_questions.create(tree_category_question: tcq)
      end
    end
  end

end
