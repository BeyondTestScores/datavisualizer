class Survey < ApplicationRecord

  has_many :questions, through: :survey_questions

end
