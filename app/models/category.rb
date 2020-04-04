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

  def path(include_self: false)
    parents = []
    parents << self if include_self
    pc = parent_category
    while pc.present?
      parents << pc
      pc = pc.parent_category
    end
    parents.reverse
  end

  def all_questions
    questions.to_a + child_categories.map(&:all_questions).flatten.uniq
  end

end
