class SchoolCategory < ApplicationRecord

  belongs_to :category
  belongs_to :school

  def name(category_or_school)
    "Value For #{try(category_or_school).try(:name)}"
  end

end
