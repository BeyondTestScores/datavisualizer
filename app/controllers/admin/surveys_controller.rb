class Admin::SurveysController < Admin::AdminController

  before_action :set_survey, only: [:show, :edit, :update, :destroy]

  def show
    add_breadcrumb @survey.name
  end

  def new
    add_breadcrumb "New Survey"

    @survey = Survey.new
  end

  def create
    @survey = Survey.new(survey_params)
    if @survey.save
      redirect_to [:admin, @survey]
    else
      raise @survey.errors.inspect
      render :new
    end
  end

  def edit
    add_breadcrumb @survey.name, [:admin, @survey]
    add_breadcrumb "Edit"
  end

  def update
    respond_to do |format|
      if @survey.update(survey_params)
        format.html { redirect_to [:admin, @survey], notice: 'Survey was successfully updated.' }
        # format.json { render :show, status: :ok, location: @survey }
      else
        format.html { render :edit }
        # format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey.destroy
    respond_to do |format|
      format.html { redirect_to admin_root_path, notice: 'Survey was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  private
  def survey_params
    params.require(:survey).permit(:name, :school_id, :kind, :survey_monkey_id, question_ids: [])
  end

  def set_survey
    @survey = Survey.find(params[:id])
  end

end
