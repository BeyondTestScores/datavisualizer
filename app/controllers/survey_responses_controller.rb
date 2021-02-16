class SurveyResponsesController < ApplicationController
  skip_forgery_protection

  def create    
    puts ""
    puts ""
    puts ""
    puts ""
    puts params.inspect
    puts ""
    puts ""
    puts ""
    puts ""
    if request.get?
      render status: 200 and return 
    end

    render status: 200
  end

end
