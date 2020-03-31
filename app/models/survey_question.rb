class SurveyQuestion < ApplicationRecord

  belongs_to :survey
  belongs_to :question

  after_destroy :destroy_survey_monkey
  after_commit :create_survey_monkey, on: :create

  scope :for, -> (question) { where(question: question) }
  scope :on_page, -> (page_id) { where(survey_monkey_page_id: page_id) }

  def create_survey_monkey
    return true unless id_previously_changed? # this shouldn't be necessary but this callback is sometimes called on update
    survey.create_survey_monkey_question(self)
  end

  def destroy_survey_monkey
    survey.remove_survey_monkey_question(self)
  end

end
