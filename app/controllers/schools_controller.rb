class SchoolsController < ApplicationController
  before_action :set_school, only: [:show]

  # GET /schools/1
  # GET /schools/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school
      @school = School.friendly.find(params[:id])
    end
end
