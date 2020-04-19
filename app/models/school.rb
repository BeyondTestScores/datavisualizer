class School < ApplicationRecord

  has_many :school_categories, dependent: :destroy

  def to_s
    name
  end

end
