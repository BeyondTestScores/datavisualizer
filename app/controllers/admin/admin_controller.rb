class Admin::AdminController < ApplicationController
  add_breadcrumb "Admin Home", :admin_root_path

  before_action :admin_authenticate

  def admin_authenticate
    return authenticate(:admin)
  end

end
