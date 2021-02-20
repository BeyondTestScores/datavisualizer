class SurveyResponsesController < ApplicationController
  skip_forgery_protection

  def create    
    if request.head?
      render plain: "OK" 
      return 
    end

    info = request.body.read

    puts ""
    puts "1"
    pp info
    puts ""
    puts "2"
    puts info
    puts ""
    puts "3"
    puts "NAME #{info["name"]}"
    puts ""
    puts "4"
    puts JSON.parse(info.to_s)
    puts ""
    puts "5"  
    puts JSON.parse(info.to_s)["name"]
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
