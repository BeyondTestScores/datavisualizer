ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module SurveyMonkeyHelper
  def survey_monkey_mock(method: :get, url: "surveys", body: nil, responses: [])
    with = {headers: {
      'Content-Type' => 'application/json',
      'Authorization' => "bearer #{Rails.application.credentials.dig(:surveymonkey)[:access_token]}"
    }}

    with[:body] = body.to_json if body != nil

    stub = stub_request(method, "https://api.surveymonkey.com/v3/#{url}").with(with)

    responses.each do |response|
      stub.to_return(status: 200, body: response.to_json, headers: {'Content-Type'=>'application/json'}).then
    end
  end
end

class ActionDispatch::IntegrationTest
  include SurveyMonkeyHelper
end
