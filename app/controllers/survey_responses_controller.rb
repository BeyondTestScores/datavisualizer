class SurveyResponsesController < ApplicationController
  skip_forgery_protection

  def create    
    if request.head?
      render plain: "OK" 
      return 
    end

    puts ""
    puts ""
    puts request.body.read
    puts ""

    info = JSON.parse(request.body.read)

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
