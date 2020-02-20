class Admin::CategoriesController < Admin::AdminController

  def new
    @category = Category.new
    @parent_categories = Category.all.sort
  end

end
