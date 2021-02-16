class Admin::SurveyResponsesController < Admin::AdminController
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
    render status: 200
  end

end
