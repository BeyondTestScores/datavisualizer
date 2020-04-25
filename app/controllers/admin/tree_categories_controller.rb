class Admin::TreeCategoriesController < Admin::AdminController

  before_action :set_tree
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :set_parent_tree_categories, only: [:new, :edit]
  before_action :set_path, only: [:show, :edit]

  def index
  end

  def show
    add_breadcrumb @category.name
  end

  def new
    parent_tree_category = TreeCategory.where(id: params[:parent_tree_category_id]).first

    if parent_tree_category.present?
      parent_tree_category.path(include_self: true).each { |ptc| add_breadcrumb ptc.name, [:admin, ptc] }
    end
    add_breadcrumb "New #{parent_tree_category.present? ? 'Subcategory' : 'Category'}"
    @tree_category = TreeCategory.new(
      parent_tree_category: parent_tree_category,
      category: Category.new(administrative_measure: params[:administrative_measure] || false)
    )
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      respond_to do |format|
        format.html { redirect_to [:admin, @category], notice: "#{@category.classification} was successfully created." }
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

  def set_parent_tree_categories
    @parent_tree_categories = TreeCategory.joins(:category).all.sort(&:name)
  end

  def category_params
    params.require(:category).permit(:name, :blurb, :descrtiption, :parent_category_id, :administrative_measure)
  end

  def set_category
    @category = Category.friendly.find(params[:id])
  end

  def set_tree
    @tree = Tree.friendly.find(params[:tree_id])
  end
end
