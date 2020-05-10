class Category < ApplicationRecord
  include ActiveModel::Dirty

  has_many :tree_categories, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1 }

  after_update_commit :sync_surveys

  include FriendlyId
  friendly_id :name, :use => [:slugged]

  scope :administrative_measure, -> { where(administrative_measure: true) }
  scope :not_administrative_measure, -> { where(administrative_measure: false) }

  def to_s
    name
  end

  def classification
    administrative_measure? ? 'Administrative measure' : 'Category'
  end

  def sync_surveys
    all_school_tree_category_questions.map(&:sync_surveys)
  end

  def tree_category_questions
    tree_categories.map(&:tree_category_questions).flatten
  end

  def school_tree_category_questions
    tree_category_questions.map(&:school_tree_category_questions).flatten
  end

  def all_school_tree_category_questions
    tree_categories.map(&:all_school_tree_category_questions).flatten
  end

end
