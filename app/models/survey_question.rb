class SurveyQuestion < ApplicationRecord

  belongs_to :survey
  belongs_to :question

  after_commit :create_survey_monkey, on: :create
  before_destroy :destroy_survey_monkey

  scope :for, -> (question) { where(question: question) }
  scope :on_page, -> (page_id) { where(survey_monkey_page_id: page_id) }

  def create_survey_monkey
    survey.create_survey_monkey_question(self)
  end

  def destroy_survey_monkey
    survey.remove_survey_monkey_question(self)
  end

end
