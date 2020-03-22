class SurveyQuestion < ApplicationRecord

  belongs_to :survey
  belongs_to :question

  after_commit :create_survey_monkey, on: :create
  after_destroy :destroy_survey_monkey

  def create_survey_monkey
    survey.create_survey_monkey_question(question)
  end

  def destroy_survey_monkey
    survey.remove_survey_monkey_question(question)
  end

end
