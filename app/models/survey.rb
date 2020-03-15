class Survey < ApplicationRecord

  has_many :survey_questions
  has_many :questions, through: :survey_questions

  validates :name, presence: true, length: { minimum: 1 }

  def to_s
    name
  end

  def category_tree
    tree = {child_categories: []}

    questions.each do |question|
        category = question.category
        question_path = []
        while category
          question_path << category
          category = category.parent_category
        end

        node = tree
        question_path.reverse.each do |category|
          category_hash = node[:child_categories].find { |cc| cc[:category].name == category.name }
          if category_hash.blank?
            category_hash = {category: category, child_categories: []}
            node[:child_categories].push(category_hash)
          end
          node[:child_categories].sort! { |a,b| a[:category].name <=> b[:category].name }
          node = category_hash
        end

        node[:questions] ||= []
        node[:questions] << question
    end

    return tree
  end

end
