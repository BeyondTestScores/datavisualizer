class SurveyResponsesController < ApplicationController
  skip_forgery_protection

  def create    
    puts ""
    puts ""
    puts ""
    puts ""
    puts survey_response_params.inspect
    puts params.inspect
    puts request.body.read.inspect
    puts ""
    puts ""
    puts ""
    puts ""
    if request.get?
      render plain: "OK" and return 
    end

    render plain: "OK"
  end

  def survey_response_params
    params.permit!
  end

end
