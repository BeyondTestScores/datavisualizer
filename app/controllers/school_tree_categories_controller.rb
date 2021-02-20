class SchoolTreeCategoriesController < ApplicationController

  before_action :set_school_tree_category, only: [:show]

  def show
    add_breadcrumb @school_tree_category.name(:school)
  end

  private
  def set_school_tree_category
    @school_tree_category = SchoolTreeCategory.find(params[:id])
    @school_tree_category.path(include_self: true).each do |ptc|
      add_breadcrumb ptc, [:admin, ptc.tree, ptc.category]
    end
  end

end
