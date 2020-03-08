require 'test_helper'

class SurveysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @survey = surveys(:one)
  end

  # test "should get index" do
  #   get surveys_url
  #   assert_response :success
  # end

  # test "should show survey" do
  #   get survey_url(@survey)
  #   assert_response :success
  # end
end
