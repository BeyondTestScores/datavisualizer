class Admin::AdminController < ApplicationController
  before_action :admin_authenticate

  def admin_authenticate
    return authenticate(:admin)
  end

end
