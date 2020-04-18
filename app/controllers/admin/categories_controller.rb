class Admin::CategoriesController < Admin::AdminController

  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :set_parent_categories, only: [:new, :edit]
  before_action :set_path, only: [:show, :edit]

  def index
  end

  def show
    add_breadcrumb @category.name
  end

  def new
    parent_category = Category.where(id: params[:parent_category_id]).first

    if parent_category.present?
      parent_category.path(include_self: true).each { |pc| add_breadcrumb pc.name, [:admin, pc] }
    end
    add_breadcrumb "New #{parent_category.present? ? 'Subcategory' : 'Category'}"
    @category = Category.new(parent_category: parent_category)
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      respond_to do |format|
        format.html { redirect_to [:admin, @category], notice: 'Category was successfully created.' }
      end
    else
      @parent_categories = Category.all.sort
      render :new
    end
  end

  def edit
    add_breadcrumb @category.name, [:admin, @category]
    add_breadcrumb "Edit"
  end

  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to [:admin, @category], notice: 'Category was successfully updated.' }
        # format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        # format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to admin_root_path, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_path
    @category.path.each { |pc| add_breadcrumb pc.name, [:admin, pc] }
  end

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
