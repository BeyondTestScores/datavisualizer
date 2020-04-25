class Tree < ApplicationRecord

  has_many :tree_categories
  has_many :surveys

  include FriendlyId
  friendly_id :name, :use => [:slugged]

end
