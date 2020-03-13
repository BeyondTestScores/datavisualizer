class Admin::QuestionsController < Admin::AdminController

  before_action :set_question, only: [:show, :edit, :update]
  before_action :set_categories, only: [:new, :edit]

  def show
  end

  def new
    @question = Question.new(category_id: params[:category_id])
  end

  def create
    @question = Question.new(question_params)
    if @question.save
      redirect_to [:admin, @question]
    else
      @categories = Category.all.sort
      render :new
    end
  end

  def edit
  end

  # PATCH/PUT /admin/questions/1
  # PATCH/PUT /admin/questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to [:admin, @question], notice: 'Question was successfully updated.' }
        # format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        # format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/questions/1
  # DELETE /admin/questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to admin_root_url, notice: 'Question was successfully destroyed.' }
      # format.json { head :no_content }
    end
  end


  private
  def set_categories
    @categories = Category.all.sort
  end

  def question_params
    params.require(:question).permit(:text, :option1, :option2, :option3, :option4, :option5, :category_id)
  end

  def set_question
    @question = Question.find(params[:id])
  end

end
