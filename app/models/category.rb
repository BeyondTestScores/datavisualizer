class Category < ApplicationRecord
  include ActiveModel::Dirty

  has_many :questions, dependent: :destroy
  belongs_to :parent_category, class_name: 'Category', foreign_key: :parent_category_id, optional: true
  has_many :child_categories, class_name: 'Category', foreign_key: :parent_category_id, dependent: :destroy
  has_many :school_categories, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1 }

  after_create :create_school_categories_for_administrative_measure
  after_update_commit :sync_surveys

  include FriendlyId
  friendly_id :name, :use => [:slugged]

  scope :root, -> { where(parent_category: nil) }
  scope :administrative_measure, -> { where(administrative_measure: true) }

  def to_s
    name
  end

  def sync_surveys
    all_questions.map(&:sync_surveys)
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

  private

  def create_school_categories_for_administrative_measure
    return unless administrative_measure?
    School.all.each do |school|
      school_categories.create(school: school)
    end
  end

end
