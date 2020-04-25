class TreeCategory < ApplicationRecord

  belongs_to :category
  belongs_to :tree

  belongs_to :parent_tree_category, class_name: 'TreeCategory', foreign_key: :parent_tree_category_id, optional: true
  has_many :child_tree_categories, class_name: 'TreeCategory', foreign_key: :parent_tree_category_id, dependent: :destroy

  has_many :tree_category_questions

  has_many :school_tree_categories

  accepts_nested_attributes_for :category

  scope :root, -> { where(parent_category: nil) }
  scope :incomplete, -> { where(administrative_measure: false).includes(:questions, :child_categories).where(questions: { id: nil }).where(child_categories_categories: { id: nil }) }

  after_create :create_school_tree_categories_for_administrative_measure

  def all_tree_category_questions
    tree_category_questions.to_a + child_tree_categories.map(&:all_questions).flatten.uniq
  end


  private

  def create_school_tree_categories_for_administrative_measure
    return unless category.administrative_measure?
    School.all.each do |school|
      school_tree_categories.create(school: school)
    end
  end

end
