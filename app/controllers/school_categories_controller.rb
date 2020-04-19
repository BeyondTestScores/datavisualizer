class SchoolCategoriesController < ApplicationController
  before_action :set_school_category, only: [:show, :edit, :update, :destroy]

  # GET /school_categories
  # GET /school_categories.json
  def index
    @school_categories = SchoolCategory.all
  end

  # GET /school_categories/1
  # GET /school_categories/1.json
  def show
  end

  # GET /school_categories/new
  def new
    @school_category = SchoolCategory.new
  end

  # GET /school_categories/1/edit
  def edit
  end

  # POST /school_categories
  # POST /school_categories.json
  def create
    @school_category = SchoolCategory.new(school_category_params)

    respond_to do |format|
      if @school_category.save
        format.html { redirect_to @school_category, notice: 'School category was successfully created.' }
        format.json { render :show, status: :created, location: @school_category }
      else
        format.html { render :new }
        format.json { render json: @school_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /school_categories/1
  # PATCH/PUT /school_categories/1.json
  def update
    respond_to do |format|
      if @school_category.update(school_category_params)
        format.html { redirect_to @school_category, notice: 'School category was successfully updated.' }
        format.json { render :show, status: :ok, location: @school_category }
      else
        format.html { render :edit }
        format.json { render json: @school_category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /school_categories/1
  # DELETE /school_categories/1.json
  def destroy
    @school_category.destroy
    respond_to do |format|
      format.html { redirect_to school_categories_url, notice: 'School category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school_category
      @school_category = SchoolCategory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def school_category_params
      params.require(:school_category).permit(:category, :school, :response_count, :answer_index_total, :zscore, :nonlikert, :year)
    end
end
