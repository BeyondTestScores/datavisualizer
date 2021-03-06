class Question < ApplicationRecord
  include ActiveModel::Dirty

  enum kind: [:for_students, :for_teachers, :for_community]

  has_many :tree_category_questions, dependent: :destroy

  validates :text, presence: true, length: { minimum: 1 }
  validates :option1, presence: true, length: { minimum: 1 }
  validates :option2, presence: true, length: { minimum: 1 }
  validates :option3, presence: true, length: { minimum: 1 }
  validates :option4, presence: true, length: { minimum: 1 }
  validates :option5, presence: true, length: { minimum: 1 }
  validates :kind, presence: true

  after_update_commit :sync_surveys

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

  def sync_surveys
    tree_category_questions.each do |tcq|
      tcq.school_tree_category_questions.each do |stcq|
        stcq.survey.update_survey_monkey_question(stcq)
      end
    end
  end

end
