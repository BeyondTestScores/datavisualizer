class Admin::SchoolTreeCategoriesController < Admin::AdminController

  before_action :set_school_tree_category, only: [:show, :edit, :update, :destroy]

  def show
    add_breadcrumb @school_tree_category.name(:school)
  end

  def new
    add_breadcrumb "New School Category"

    @school_tree_category = SchoolTreeCategory.new
  end

  def create
    @school_tree_category = SchoolTreeCategory.new(school_tree_category_params)
    if @school_tree_category.save
      respond_to do |format|
        format.html { redirect_to [:admin, @school_tree_category], notice: 'Administrative measure was successfully created.' }
      end
    else
      render :new
    end
  end

  def edit
    add_breadcrumb @school_tree_category.name(:school), [:admin, @school_tree_category]
    add_breadcrumb "Edit"
  end

  def update
    respond_to do |format|
      if @school_tree_category.update(school_tree_category_params)
        tc = @school_tree_category.tree_category
        format.html { redirect_to [:admin, tc.tree, tc.category], notice: "#{@school_tree_category.name(:school)} was successfully updated." }
        # format.json { render :show, status: :ok, location: @school_tree_category }
      else
        format.html { render :edit }
        # format.json { render json: @school_tree_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @school_tree_category.destroy
    respond_to do |format|
      format.html { redirect_to admin_root_path, notice: "Administrative measure was successfully destroyed." }
      format.json { head :no_content }
    end
  end



  private
  def school_tree_category_params
    params.require(:school_tree_category).permit(:nonlikert, :category_id, :school_id)
  end

  def set_school_tree_category
    @school_tree_category = SchoolTreeCategory.find(params[:id])
    @school_tree_category.path(include_self: true).each do |ptc|
      add_breadcrumb ptc, [:admin, ptc.tree, ptc.category]
    end
  end

end
