class Category < ApplicationRecord
  include ActiveModel::Dirty

  has_many :questions, dependent: :destroy
  belongs_to :parent_category, class_name: 'Category', foreign_key: :parent_category_id, optional: true
  has_many :child_categories, class_name: 'Category', foreign_key: :parent_category_id, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1 }

  after_update_commit :sync_surveys

  include FriendlyId
  friendly_id :name, :use => [:slugged]

  scope :root, -> { where(parent_category: nil) }

  def to_s
    name
  end

  def sync_surveys
    questions.map(&:sync_surveys)
  end

end
