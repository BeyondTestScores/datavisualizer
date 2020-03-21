class Question < ApplicationRecord
  belongs_to :category
  has_many :surveys, through: :survey_questions
  has_many :survey_questions, dependent: :destroy

  validates :text, presence: true, length: { minimum: 1 }
  validates :option1, presence: true, length: { minimum: 1 }
  validates :option2, presence: true, length: { minimum: 1 }
  validates :option3, presence: true, length: { minimum: 1 }
  validates :option4, presence: true, length: { minimum: 1 }
  validates :option5, presence: true, length: { minimum: 1 }

  # after_commit :sync_surveys

  def to_s
    text
  end

  # def sync_surveys
  #   surveys.each { |survey| survey.update_survey_monkey_question(self) }
  # end

end
