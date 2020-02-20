class Admin::CategoriesController < Admin::AdminController

  before_action :set_category, only: [:show]

  def index
  end

  def show
  end

  def new
    @category = Category.new
    @parent_categories = Category.all.sort
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to [:admin, @category]
    else
      @parent_categories = Category.all.sort
      render :new
    end
  end


  private
  def category_params
    params.require(:category).permit(:name, :blurb, :descrtiption, :parent_category_id)
  end

  def set_category
    @category = Category.friendly.find(params[:id])
  end

end
