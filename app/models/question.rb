class Question < ApplicationRecord
  belongs_to :category
  has_many :survey_questions, dependent: :destroy
  has_many :surveys, through: :survey_questions, dependent: :destroy

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

  def survey_monkey_structure(position=1)
    {
      "family": "single_choice",
      "subtype": "vertical",
      "answers": {
        "choices": [
          {
            "text": option1,
            "position": 1
          },
          {
            "text": option2,
            "position": 2
          },
          {
            "text": option3,
            "position": 3
          },
          {
            "text": option4,
            "position": 4
          },
          {
            "text": option5,
            "position": 5
          }
        ]
      },
      "headings": [
        {
          "heading": text
        }
      ],
      "position": position
    }
  end

  # def sync_surveys
  #   surveys.each { |survey| survey.update_survey_monkey_question(self) }
  # end

end
