class Admin::SurveysController < Admin::AdminController

  before_action :set_survey, only: [:show]

  def show
  end

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(survey_params)
    if @survey.save
      redirect_to [:admin, @survey]
    else
      render :new
    end
  end


  private
  def survey_params
    params.require(:survey).permit(:name, :survey_monkey_id, question_ids: [])
  end

  def set_survey
    @survey = Survey.find(params[:id])
  end

end
