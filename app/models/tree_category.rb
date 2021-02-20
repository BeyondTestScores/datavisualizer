class TreeCategory < ApplicationRecord

  belongs_to :category
  belongs_to :tree

  belongs_to :parent_tree_category, class_name: 'TreeCategory', foreign_key: :parent_tree_category_id, optional: true
  has_many :child_tree_categories, class_name: 'TreeCategory', foreign_key: :parent_tree_category_id, dependent: :destroy

  has_many :tree_category_questions, dependent: :destroy

  has_many :school_tree_categories, dependent: :destroy

  accepts_nested_attributes_for :category

  default_scope { joins(:tree, :category) }

  scope :root, -> { where(parent_tree_category: nil) }
  scope :for_category, -> (category) { where(category: category) }
  scope :incomplete, -> { joins(:category).merge(Category.not_administrative_measure).includes(:tree_category_questions, :child_tree_categories).where(tree_category_questions: { id: nil }).where(child_tree_categories_tree_categories: { id: nil }) }
  scope :administrative_measure, -> { joins(:category).merge(Category.administrative_measure) }
  scope :missing_administrative_measure, -> { where(nonlikert: [nil, '']).merge(TreeCategory.administrative_measure) }

  before_validation :assign_tree_from_parent
  after_create :create_school_tree_categories
  after_save :update_school_tree_categories, if: :administrative_measure?

  def name
    category.name
  end

  def classification
    category.classification
  end

  def to_s
    name
  end

  def school_tree_category_questions(school=nil)
    tree_category_questions.map do |tcq|
      stcqs = tcq.school_tree_category_questions
      stcqs = stcqs.for_school(school) if school.present?
      stcqs
    end.flatten
  end

  def all_tree_category_questions
    tree_category_questions.to_a + child_tree_categories.map(&:all_tree_category_questions).flatten.uniq
  end

  def all_school_tree_category_questions
    school_tree_category_questions.to_a + child_tree_categories.map(&:all_school_tree_category_questions).flatten.uniq
  end

  def school_tree_category(school)
    school_tree_categories.for_school(school).first
  end

  def administrative_measure?
    category.administrative_measure?
  end

  def path(include_self: false)
    parents = []
    parents << self if include_self
    ptc = parent_tree_category
    while ptc.present?
      parents << ptc
      ptc = ptc.parent_tree_category
    end
    parents.reverse
  end

  private

  def create_school_tree_categories    
    School.all.each do |school|
      school_tree_categories.find_or_create_by(school: school)
    end
  end

  def assign_tree_from_parent
    return unless tree.blank? && parent_tree_category.present?
    self.tree = parent_tree_category.tree
  end

  def update_school_tree_categories
    puts ""
    puts ""
    puts "HI"
    puts ""
    puts ""
    puts ""
    school_tree_categories.each { |stc| stc.save! }
  end

end
