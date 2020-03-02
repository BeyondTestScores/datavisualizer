class Question < ApplicationRecord
  belongs_to :category

  validates :text, presence: true, length: { minimum: 1 }
  validates :option1, presence: true, length: { minimum: 1 }
  validates :option2, presence: true, length: { minimum: 1 }
  validates :option3, presence: true, length: { minimum: 1 }
  validates :option4, presence: true, length: { minimum: 1 }
  validates :option5, presence: true, length: { minimum: 1 }

end
