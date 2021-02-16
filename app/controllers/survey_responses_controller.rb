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
      render plain: "OK" and return 
    end

    render plain: "OK"
  end

end
