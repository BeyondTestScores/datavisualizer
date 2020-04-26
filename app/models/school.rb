class School < ApplicationRecord

  has_many :school_tree_categories, dependent: :destroy
  has_many :school_tree_category_questions, dependent: :destroy

  has_many :surveys, dependent: :destroy

  after_create :create_school_tree_categories_for_administrative_measures

  def to_s
    name
  end

  def create_school_tree_categories_for_administrative_measures
    Category.administrative_measure.includes(:tree_categories).each do |c|
      c.tree_categories.each do |tc|
        next if school_tree_categories.find { |sc| sc.tree_category == tc.id }
        school_tree_categories.create(tree_category: tc)
      end
    end
  end

end
