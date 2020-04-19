class SchoolCategory < ApplicationRecord

  belongs_to :category
  belongs_to :school

  def name(category_or_school)
    text = category_or_school.blank? ? "#{category} at #{school}" : try(category_or_school)
    "Value For #{text}"
  end

end
