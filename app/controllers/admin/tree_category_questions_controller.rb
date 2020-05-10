class Admin::TreeCategoryQuestionsController < Admin::AdminController

  before_action :set_tree
  before_action :set_category
  before_action :set_tree_category
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :set_tree_category_question, only: [:show, :edit, :update, :destroy]
  before_action :set_tree_categories, only: [:new, :edit]
  before_action :set_path, only: [:show, :edit]

  def show
    add_breadcrumb @tree_category_question.to_s.truncate(50)
  end

  def new
    @tree_category.path(include_self: true).each do |ptc|
      add_breadcrumb ptc.name, [:admin, ptc.tree, ptc.category]
    end

    add_breadcrumb "New Question"

    @tree_category_question = @tree_category.tree_category_questions.new(
      tree_category: @tree_category,
      question: Question.new
    )
  end

  def create
    @tree_category_question = @tree_category.tree_category_questions.new(tree_category_question_params)
    if @tree_category_question.save
      respond_to do |format|
        format.html { redirect_to [:admin, @tree, @category, @tree_category_question.question], notice: 'Question was successfully created.' }
      end
    else
      set_tree_categories
      render :new
    end
  end

  def edit
    add_breadcrumb @tree_category_question.to_s.truncate(50), [:admin, @tree, @category, @tree_category_question.question]
    add_breadcrumb "Edit"
  end

  # PATCH/PUT /admin/questions/1
  # PATCH/PUT /admin/questions/1.json
  def update
    respond_to do |format|
      if @tree_category_question.update(tree_category_question_params)
        format.html { redirect_to [:admin, @tree, @category, @question], notice: 'Question was successfully updated.' }
        # format.json { render :show, status: :ok, location: @question }
      else
        raise @tree_category_question.inspect
        set_tree_categories
        format.html { render :edit }
        # format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/questions/1
  # DELETE /admin/questions/1.json
  def destroy
    @tree_category_question.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @tree, @category], notice: 'Question was successfully destroyed.' }
      # format.json { head :no_content }
    end
  end


  private
  def set_path
    path = @tree_category.path(include_self: true)
    path.each { |ptc| add_breadcrumb ptc.name, [:admin, ptc.tree, ptc.category] }
  end

  def set_tree_categories
    @tree_categories = @tree.tree_categories.sort
  end

  def tree_category_question_params
    params.require(:tree_category_question).permit(:tree_category_id, question_attributes: [:id, :text, :option1, :option2, :option3, :option4, :option5])
  end

  def set_tree_category_question
    @tree_category_question = @tree_category.tree_category_questions.for(@question).first
  end

  def set_question
    @question = Question.find(params[:id])
  end

  def set_tree_category
    @tree_category = @tree.tree_categories.for(@category).first
  end

  def set_category
    @category = Category.friendly.find(params[:category_id])
  end

  def set_tree
    @tree = Tree.friendly.find(params[:tree_id])
    add_breadcrumb @tree, [:admin, @tree]
  end

end
