class Tree < ApplicationRecord

  has_many :tree_categories, dependent: :destroy
  has_many :surveys, dependent: :destroy

  include FriendlyId
  friendly_id :name, :use => [:slugged]

  def to_s
    name
  end

end
