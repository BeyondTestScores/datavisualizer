class Admin::QuestionsController < Admin::AdminController

  before_action :set_question, only: [:show, :edit]

  def show
  end

  def new
    @question = Question.new(category_id: params[:category_id])
    @categories = Category.all.sort
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
    @categories = Category.all.sort
  end


  private
  def question_params
    params.require(:question).permit(:text, :option1, :option2, :option3, :option4, :option5, :category_id)
  end

  def set_question
    @question = Question.find(params[:id])
  end

end
