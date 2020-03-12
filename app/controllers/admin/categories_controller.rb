class Admin::CategoriesController < Admin::AdminController

  before_action :set_category, only: [:show, :edit]
  before_action :set_parent_categories, only: [:new, :edit]

  def index
  end

  def show
  end

  def new
    @category = Category.new(parent_category_id: params[:parent_category_id])
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

  def edit
  end


  private
  def set_parent_categories
    @parent_categories = Category.all.sort
  end

  def category_params
    params.require(:category).permit(:name, :blurb, :descrtiption, :parent_category_id)
  end

  def set_category
    @category = Category.friendly.find(params[:id])
  end

end
