class Admin::CategoriesController < Admin::AdminController

  def new
    @category = Category.new
  end

end
