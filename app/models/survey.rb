class Survey < ApplicationRecord

  has_many :survey_questions
  has_many :questions, through: :survey_questions

  validates :name, presence: true, length: { minimum: 1 }

  def to_s
    name
  end

  def category_tree
    tree = {children: {}}

    questions.each do |question|
        category = question.category
        question_path = []
        while category
          question_path << category
          category = category.parent_category
        end

        node = tree
        question_path.reverse.each do |category|
          category_hash = node[:children][category.name]
          category_hash = {category: category, children: {}} if category_hash.blank?
          node[:children][category.name] = category_hash
          node = category_hash
        end
        node[:questions] ||= []
        node[:questions] << question
    end

    return tree
  end

end
