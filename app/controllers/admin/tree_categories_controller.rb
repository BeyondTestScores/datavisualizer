class Admin::TreeCategoriesController < Admin::AdminController

  before_action :set_tree
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :set_tree_category, only: [:show, :edit, :update, :destroy]
  before_action :set_parent_tree_categories, only: [:new, :edit]
  before_action :set_path, only: [:show, :edit]

  def index
  end

  def show
    add_breadcrumb @category.name
  end

  def new
    parent_tree_category = @tree.tree_categories.where(id: params[:parent_tree_category_id]).first

    if parent_tree_category.present?
      parent_tree_category.path(include_self: true).each { |ptc| add_breadcrumb ptc.name, [:admin, ptc.tree, ptc.category] }
    end
    add_breadcrumb "New #{parent_tree_category.present? ? 'Subcategory' : 'Category'}"
    @tree_category = @tree.tree_categories.new(
      parent_tree_category: parent_tree_category,
      category: Category.new(administrative_measure: params[:administrative_measure] || false)
    )
  end

  def create
    @tree_category = @tree.tree_categories.new(tree_category_params)
    if @tree_category.save
      respond_to do |format|
        format.html { redirect_to [:admin, @tree, @tree_category.category], notice: "#{@tree_category.classification} was successfully created." }
      end
    else
      set_parent_tree_categories
      render :new
    end
  end

  def edit
    add_breadcrumb @category.name, [:admin, @tree, @category]
    add_breadcrumb "Edit"
  end

  def update
    respond_to do |format|
      if @tree_category.update(tree_category_params)
        format.html { redirect_to [:admin, @tree, @category], notice: 'Category was successfully updated.' }
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
    @tree_category.path.each { |ptc| add_breadcrumb ptc.name, [:admin, ptc.tree, ptc.category] }
  end

  def set_parent_tree_categories
    @parent_tree_categories = @tree.tree_categories.all.sort
  end

  def tree_category_params
    params.require(:tree_category).permit(:parent_tree_category_id, category_attributes: [:id, :name, :blurb, :description, :administrative_measure])
  end

  def set_tree_category
    @tree_category = @tree.tree_categories.for_category(@category).first
  end

  def set_category
    @category = Category.friendly.find(params[:id])
  end

  def set_tree
    @tree = Tree.friendly.find(params[:tree_id])
    add_breadcrumb @tree, [:admin, @tree]
  end
end
