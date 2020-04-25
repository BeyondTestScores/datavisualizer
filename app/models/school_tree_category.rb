class SchoolTreeCategory < ApplicationRecord

  belongs_to :tree_category
  belongs_to :school

  scope :missing_administrative_measure, -> { where(nonlikert: [nil, '']).joins(tree_category: :category).merge(Category.administrative_measure) }

  def to_s
    name
  end

  def name(category_or_school=nil)
    text = category_or_school.blank? ? "#{category} at #{school}" : try(category_or_school)
    "Value For #{text}"
  end

end
