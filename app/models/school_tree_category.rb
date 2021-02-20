class SchoolTreeCategory < ApplicationRecord

  belongs_to :tree_category
  belongs_to :school

  after_save :update_totals, if: :administrative_measure?

  default_scope { joins(:tree_category, :school) }

  scope :missing_administrative_measure, -> { 
    where(nonlikert: [nil, '']).joins(tree_category: :category).merge(Category.administrative_measure) 
  }
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

  def administrative_measure?
    tree_category.administrative_measure?
  end

  def responses_average
    return nil if responses_count == 0
    (responses_sum.to_f / responses_count.to_f).round(1)
  end

  def update_totals
    sum = 0
    count = 0

    if (nonlikert.present?) 
      return if tree_category.nonlikert.blank?
      factor = 10
      sum = 5 * factor * nonlikert / tree_category.nonlikert
      count = factor
    else
      stcqs = tree_category.school_tree_category_questions(school)
      sum += stcqs.sum(&:responses_sum)
      count += stcqs.sum(&:responses_count)
  
      cstcs = tree_category.child_tree_categories.map do |ctc|
        ctc.school_tree_category(school)
      end.compact
      sum += cstcs.sum(&:responses_sum)
      count += cstcs.sum(&:responses_count)
    end
    
    update_columns(responses_sum: sum, responses_count: count)

    parent_tree_category = tree_category.parent_tree_category
    return unless parent_tree_category.present?

    parent_school_tree_category = parent_tree_category.school_tree_category(school)
    return unless parent_school_tree_category.present?

    parent_school_tree_category.update_totals 
  end

end
