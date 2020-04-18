class Admin::SchoolsController < Admin::AdminController

  before_action :set_school, only: [:show, :edit, :update, :destroy]

  def show
    add_breadcrumb @school.name
  end

  def new
    add_breadcrumb "New School"

    @school = School.new
  end

  def create
    @school = School.new(school_params)
    if @school.save
      respond_to do |format|
        format.html { redirect_to [:admin, @school], notice: 'School was successfully created.' }
      end
    else
      render :new
    end
  end

  def edit
    add_breadcrumb @school.name, [:admin, @school]
    add_breadcrumb "Edit"
  end

  def update
    respond_to do |format|
      if @school.update(school_params)
        format.html { redirect_to [:admin, @school], notice: 'School was successfully updated.' }
        # format.json { render :show, status: :ok, location: @school }
      else
        format.html { render :edit }
        # format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @school.destroy
    respond_to do |format|
      format.html { redirect_to admin_root_path, notice: 'School was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  private
  def school_params
    params.require(:school).permit(:name, :school_monkey_id, question_ids: [])
  end

  def set_school
    @school = School.find(params[:id])
  end

end
