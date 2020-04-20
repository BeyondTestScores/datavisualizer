class School < ApplicationRecord

  has_many :school_categories, dependent: :destroy

  after_create :create_school_categories_for_administrative_measures

  def to_s
    name
  end

  def create_school_categories_for_administrative_measures
    Category.administrative_measure.each do |c|
      next if school_categories.find { |sc| sc.category_id == c.id }
      school_categories.create(category: c)
    end
  end

end
