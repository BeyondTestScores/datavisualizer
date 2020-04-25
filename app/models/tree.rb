class Tree < ApplicationRecord

  has_many :tree_categories
  has_many :surveys

end
