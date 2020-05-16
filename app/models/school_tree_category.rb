class SchoolTreeCategory < ApplicationRecord

  belongs_to :tree_category
  belongs_to :school

  default_scope { joins(:tree_category, :school) }

  scope :missing_administrative_measure, -> { where(nonlikert: [nil, '']).joins(tree_category: :category).merge(Category.administrative_measure) }

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

end
