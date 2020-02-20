class Admin::CategoriesController < Admin::AdminController

  def show
  end

  def new
    @category = Category.new
    @parent_categories = Category.all.sort
  end

  def create
    category = Category.new(category_params)
    if category.save
      redirect_to category
    else
      render :new
    end
  end


  private
  def category_params
    params.require(:category).permit(:name, :blurb, :descrtiption, :parent_category_id)
  end

end
