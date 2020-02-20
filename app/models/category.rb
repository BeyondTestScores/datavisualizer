class Category < ApplicationRecord
  has_many :questions
  belongs_to :parent_category, class_name: 'Category', foreign_key: :parent_category_id, optional: true
  has_many :child_categories, class_name: 'Category', foreign_key: :parent_category_id

end
