class TreesController < ApplicationController

  before_action :set_tree, only: [:show]

  def show
    add_breadcrumb @tree.name
  end

  private
  def set_tree
    @tree = Tree.friendly.find(params["id"])
  end

end
