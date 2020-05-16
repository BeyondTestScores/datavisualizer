class Tree < ApplicationRecord

  has_many :tree_categories, dependent: :destroy
  has_many :surveys, dependent: :destroy

  include FriendlyId
  friendly_id :name, :use => [:slugged]

  after_save :sync_surveys

  def to_s
    name
  end

  def sync_surveys
    
  end

end
