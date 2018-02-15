class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_super_admin
  
  def index
  end
end
