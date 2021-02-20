class SurveyResponsesController < ApplicationController
  skip_forgery_protection

  def create    
    if request.get?
      render plain: "OK" and return 
    end

    info = JSON.parse(request.body.read)

    puts ""
    puts ""
    pp info
    puts ""
    puts ""  

    survey = Survey.find_by_survey_monkey_id[info["resources"]["survey_id"]]
    survey.create_survey_responses(info["resources"]["respondent_id"], info["object_id"])

    render plain: "OK"
  end

  def survey_response_params
    params.permit!
  end

end
