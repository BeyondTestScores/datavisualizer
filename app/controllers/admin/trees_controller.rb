class Admin::TreesController < Admin::AdminController

  before_action :set_tree, only: [:show, :edit, :update, :destroy]

  def show
    add_breadcrumb @tree.name
  end

  def new
    add_breadcrumb "New Tree"

    @tree = Tree.new(name: "#{Date.today.year}-#{Date.today.year + 1}")
  end

  def create
    @tree = Tree.new(tree_params)
    if @tree.save
      redirect_to [:admin, @tree]
    else
      render :new
    end
  end

  def edit
    add_breadcrumb @tree.name, [:admin, @tree]
    add_breadcrumb "Edit"
  end

  def update
    respond_to do |format|
      if @tree.update(tree_params)
        format.html { redirect_to [:admin, @tree], notice: 'Tree was successfully updated.' }
        # format.json { render :show, status: :ok, location: @tree }
      else
        format.html { render :edit }
        # format.json { render json: @tree.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @tree.destroy
    respond_to do |format|
      format.html { redirect_to admin_root_path, notice: 'Tree was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  private
  def tree_params
    params.require(:tree).permit(:name)
  end

  def set_tree
    @tree = Tree.friendly.find(params["id"])
  end

end
