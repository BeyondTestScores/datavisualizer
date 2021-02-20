class SchoolTreeCategoriesController < ApplicationController

  before_action :set_tree, only: [:show]
  before_action :set_school, only: [:show]
  before_action :set_category, only: [:show]
  before_action :set_school_tree_category, only: [:show]

  def show
    add_breadcrumb @category
  end

  private
  def set_school_tree_category
    @tree_category = @tree.tree_categories.for_category(@category).first
    @school_tree_category = @tree_category.school_tree_categories.for_school(@school).first
    @school_tree_category.path(include_self: false).each do |ptc|
      add_breadcrumb ptc.category, tree_school_category_path(@tree, @school, ptc.category)
    end
  end

  def set_category
    @category = Category.friendly.find(params[:id])
  end

  def set_school
    @school = School.friendly.find(params[:school_id])
    add_breadcrumb @school, @school
  end

  def set_tree
    @tree = Tree.friendly.find(params[:tree_id])
    add_breadcrumb @tree, @tree
  end


end
