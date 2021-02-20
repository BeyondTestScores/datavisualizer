class SchoolTreesController < ApplicationController
  
  before_action :set_tree, only: [:show]
  before_action :set_school, only: [:show]

  def show
    
  end

  private
  def set_school
    @school = School.friendly.find(params[:id])
    add_breadcrumb @school
  end

  def set_tree
    @tree = Tree.friendly.find(params["tree_id"])
    add_breadcrumb @tree, @tree
  end

end
