class Admin::SchoolCategoriesController < Admin::AdminController

  before_action :set_school_category, only: [:show, :edit, :update, :destroy]

  def show
    add_breadcrumb @school_category.name(:school)
  end

  def new
    add_breadcrumb "New School Category"

    @school_category = SchoolCategory.new
  end

  def create
    @school_category = SchoolCategory.new(school_category_params)
    if @school_category.save
      respond_to do |format|
        format.html { redirect_to [:admin, @school_category], notice: 'Administrative measure was successfully created.' }
      end
    else
      render :new
    end
  end

  def edit
    add_breadcrumb @school_category.name(:school), [:admin, @school_category]
    add_breadcrumb "Edit"
  end

  def update
    respond_to do |format|
      if @school_category.update(school_category_params)
        format.html { redirect_to [:admin, @school_category], notice: 'Administrative measure was successfully updated.' }
        # format.json { render :show, status: :ok, location: @school_category }
      else
        format.html { render :edit }
        # format.json { render json: @school_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @school_category.destroy
    respond_to do |format|
      format.html { redirect_to admin_root_path, notice: "Administrative measure was successfully destroyed." }
      format.json { head :no_content }
    end
  end



  private
  def school_category_params
    params.require(:school_category).permit(:nonlikert, :category_id, :school_id)
  end

  def set_school_category
    @school_category = SchoolCategory.find(params[:id])
  end

end
