class SchoolCategory < ApplicationRecord

  belongs_to :category
  belongs_to :school

  scope :missing_administrative_measure, -> { where(nonlikert: [nil, '']).joins(:category).merge(Category.administrative_measure) }

  def to_s
    name
  end

  def name(category_or_school=nil)
    text = category_or_school.blank? ? "#{category} at #{school}" : try(category_or_school)
    "Value For #{text}"
  end

end
