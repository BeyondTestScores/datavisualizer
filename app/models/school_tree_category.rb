class SchoolTreeCategory < ApplicationRecord

  belongs_to :tree_category
  belongs_to :school

  default_scope { joins(:tree_category, :school) }

  scope :missing_administrative_measure, -> { where(nonlikert: [nil, '']).joins(tree_category: :category).merge(Category.administrative_measure) }
  scope :for_school, -> (school) { where(school: school) }

  def to_s
    name
  end

  def name(tree_category_or_school=nil)
    text = tree_category_or_school.blank? ? "#{tree_category} at #{school}" : try(tree_category_or_school)
    "Value For #{text}"
  end

  def path(include_self: false)
    tree_category.path(include_self: include_self)
  end

  def tree
    tree_category.tree
  end

  def category
    tree_category.category
  end

  def update_totals
    sum = 0
    count = 0
    tree_category.all_tree_category_questions.each do |tcq|
      stcqs = tcq.school_tree_category_questions.for_school(school)
      sum += stcqs.sum(&:responses_sum)
      count += stcqs.sum(&:responses_count)
    end
    update(responses_sum: sum, responses_count: count)

    parent_tree_category = tree_category.parent_tree_category
    return unless parent_tree_category.present?

    parent_school_tree_category = parent_tree_category.school_tree_categories.for_school(school).first
    return unless parent_school_tree_category.present?

    parent_school_tree_category.update_totals 
  end

end
